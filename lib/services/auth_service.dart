import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../models/user.dart';
import 'pocketbase_client.dart';

class AuthService {
  String _getFeaturedImageUrl(PocketBase pb, RecordModel userModel) {
    final featuredImageName = userModel.getStringValue('featuredImage');
    return pb.files.getUrl(userModel, featuredImageName).toString();
  }

  void Function(User? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    if (onAuthChange != null) {
      getPocketbaseInstance().then((pb) {
        pb.authStore.onChange.listen((event) {
          onAuthChange!(event.record == null
              ? null
              : User.fromJson(event.record!.toJson()));
        });
      });
    }
  }

  Future<User> signup(
      String email, String password, String phone, String name) async {
    final pb = await getPocketbaseInstance();

    try {
      final record = await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'phoneNumber': phone,
        'name': name,
        'role': 'customer'
      });
      return User.fromJson(record.toJson());
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }

  Future<User> login(String email, String password) async {
    final pb = await getPocketbaseInstance();

    try {
      final authRecord =
          await pb.collection('users').authWithPassword(email, password);
      return User.fromJson(authRecord.record.toJson());
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred');
    }
  }

  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }

  // Future<User?> getUserFromStore() async {
  //   try {
  //     final pb = await getPocketbaseInstance();
  //
  //     final authStoreModel = pb.authStore.model;
  //     if (authStoreModel == null) {
  //       return null;
  //     }
  //
  //     final userId = authStoreModel.id;
  //     final record = await pb.collection('users').getOne(userId);
  //     // final user = User.fromJson(record.data);
  //
  //     return User.fromJson(
  //       record.toJson()
  //         ..addAll({'imageUrl': _getFeaturedImageUrl(pb, record)}),
  //     );
  //   } catch (error) {
  //     return null;
  //   }
  // }

  Future<User> getUserFromStore() async {
    final pb = await getPocketbaseInstance();
    final authStoreModel = pb.authStore.model;
    final userId = authStoreModel.id;

    try {
      final record = await pb.collection('users').getOne(userId);

      return User.fromJson(
        record.toJson()..addAll({'imageUrl': _getFeaturedImageUrl(pb, record)}),
      );
    } catch (error) {
      if (error is ClientException) {
        throw Exception('Error: ${error.response['message']}');
      }
      throw Exception('An error occurred while fetching the user details');
    }
  }

  Future<User> updateUser(User user) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = user.toJson();
      List<http.MultipartFile> files = [];

      if (user.featuredImage != null) {
        files.add(
          http.MultipartFile.fromBytes(
            'featuredImage',
            await user.featuredImage!.readAsBytes(),
            filename: user.featuredImage!.uri.pathSegments.last,
          ),
        );
      }

      final record = await pb.collection('users').update(
        user.id,
        body: body,
        files: files,
      );

      return user.copyWith(
        imageUrl: user.featuredImage != null
            ? _getFeaturedImageUrl(pb, record)
            : user.imageUrl,
      );
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred while updating the user');
    }
  }


}
