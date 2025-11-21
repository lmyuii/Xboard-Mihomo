import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/sdk/xboard_sdk.dart' as sdk;

/// XBoard 认证仓储实现
class XBoardAuthRepository implements AuthRepository {
  final _logger = FileLogger('XBoardAuthRepository');

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('登录请求: $email');
      
      await sdk.XBoardSDK.login(
        email: email,
        password: password,
      );
      
      _logger.info('登录成功');
      return Result.success(null);
      
    } on XBoardException catch (e) {
      _logger.info('登录失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('登录异常: $e');
      return Result.failure(
        XBoardException(
          code: 'LOGIN_ERROR',
          message: '登录失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
    String? emailCode,
    String? inviteCode,
  }) async {
    try {
      _logger.info('注册请求: $email');
      
      await sdk.XBoardSDK.register(
        email: email,
        password: password,
        emailCode: emailCode,
        inviteCode: inviteCode,
      );
      
      _logger.info('注册成功');
      return Result.success(null);
      
    } on XBoardException catch (e) {
      _logger.info('注册失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('注册异常: $e');
      return Result.failure(
        XBoardException(
          code: 'REGISTER_ERROR',
          message: '注册失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      _logger.info('登出请求');
      
      await sdk.XBoardSDK.logout();
      
      _logger.info('登出成功');
      return Result.success(null);
      
    } on XBoardException catch (e) {
      _logger.info('登出失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('登出异常: $e');
      return Result.failure(
        XBoardException(
          code: 'LOGOUT_ERROR',
          message: '登出失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<void>> sendVerificationCode(String email) async {
    try {
      _logger.info('发送验证码: $email');
      
      await sdk.XBoardSDK.sendVerificationCode(email);
      
      _logger.info('验证码发送成功');
      return Result.success(null);
      
    } on XBoardException catch (e) {
      _logger.info('发送验证码失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('发送验证码异常: $e');
      return Result.failure(
        XBoardException(
          code: 'SEND_CODE_ERROR',
          message: '发送验证码失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String password,
    required String emailCode,
  }) async {
    try {
      _logger.info('重置密码: $email');
      
      await sdk.XBoardSDK.resetPassword(
        email: email,
        password: password,
        emailCode: emailCode,
      );
      
      _logger.info('密码重置成功');
      return Result.success(null);
      
    } on XBoardException catch (e) {
      _logger.info('重置密码失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('重置密码异常: $e');
      return Result.failure(
        XBoardException(
          code: 'RESET_PASSWORD_ERROR',
          message: '重置密码失败: $e',
        ),
      );
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await sdk.XBoardSDK.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getAuthToken() async {
    return await sdk.XBoardSDK.getAuthToken();
  }
}
