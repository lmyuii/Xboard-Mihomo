import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/infrastructure/infrastructure.dart';

/// Repository Provider 文件
/// 
/// 提供所有 Repository 的依赖注入
/// 
/// 通过修改这里的 Provider，可以轻松切换不同的面板实现
/// 例如：从 XBoard 切换到 V2Board

// ========== 用户相关 ==========

/// 用户仓储 Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  // TODO: 未来根据配置动态选择实现
  // final panelType = ref.watch(panelTypeProvider);
  // if (panelType == 'v2board') return V2BoardUserRepository();
  
  return XBoardUserRepository();
});

/// 认证仓储 Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return XBoardAuthRepository();
});

// ========== 套餐和订阅 ==========

/// 套餐仓储 Provider
final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return XBoardPlanRepository();
});

/// 订阅仓储 Provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return XBoardSubscriptionRepository();
});

// ========== 订单和支付 ==========

/// 订单仓储 Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return XBoardOrderRepository();
});

/// 支付仓储 Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return XBoardPaymentRepository();
});

// ========== 邀请和佣金 ==========

/// 邀请仓储 Provider
final inviteRepositoryProvider = Provider<InviteRepository>((ref) {
  return XBoardInviteRepository();
});

// ========== 系统功能 ==========

/// 公告仓储 Provider
final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return XBoardNoticeRepository();
});

/// 工单仓储 Provider
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return XBoardTicketRepository();
});
