import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/sdk/xboard_sdk.dart' as sdk;
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart' as xb_sdk;

/// XBoard 工单仓储实现
class XBoardTicketRepository implements TicketRepository {
  final _logger = FileLogger('XBoardTicketRepository');

  @override
  Future<Result<List<DomainTicket>>> getTickets() async {
    try {
      _logger.info('获取工单列表...');
      
      final tickets = await sdk.XBoardSDK.getTickets();
      
      final domainTickets = tickets.map(_mapToDomain).toList();
      
      _logger.info('工单列表获取成功，共 ${domainTickets.length} 个');
      return Result.success(domainTickets);
      
    } on XBoardException catch (e) {
      _logger.info('获取工单列表失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('获取工单列表异常: $e');
      return Result.failure(
        XBoardException(
          code: 'GET_TICKETS_ERROR',
          message: '获取工单列表失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<DomainTicket>> getTicketDetail(int ticketId) async {
    try {
      _logger.info('获取工单详情: $ticketId');
      
      // getTicketDetail 返回 TicketDetail (通过 Ticket 别名)
      final ticketDetail = await sdk.XBoardSDK.getTicketDetail(ticketId);
      
      if (ticketDetail == null) {
        return Result.failure(
          XBoardException(
            code: 'TICKET_NOT_FOUND',
            message: '工单不存在',
          ),
        );
      }
      
      final domainTicket = _mapDetailToDomain(ticketDetail);
      
      _logger.info('工单详情获取成功');
      return Result.success(domainTicket);
      
    } on XBoardException catch (e) {
      _logger.info('获取工单详情失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('获取工单详情异常: $e');
      return Result.failure(
        XBoardException(
          code: 'GET_TICKET_DETAIL_ERROR',
          message: '获取工单详情失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<DomainTicket>> createTicket({
    required String subject,
    required String message,
    required int priority,
  }) async {
    try {
      _logger.info('创建工单: $subject');
      
      // createTicket 返回 Ticket (基本类型)
      final ticket = await sdk.XBoardSDK.createTicket(
        subject: subject,
        level: priority,
        message: message,
      );
      
      if (ticket == null) {
        return Result.failure(
          XBoardException(
            code: 'CREATE_TICKET_FAILED',
            message: '创建工单失败',
          ),
        );
      }
      
      final domainTicket = _mapToDomain(ticket);
      
      _logger.info('工单创建成功');
      return Result.success(domainTicket);
      
    } on XBoardException catch (e) {
      _logger.info('创建工单失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('创建工单异常: $e');
      return Result.failure(
        XBoardException(
          code: 'CREATE_TICKET_ERROR',
          message: '创建工单失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<void>> replyTicket({
    required int ticketId,
    required String message,
  }) async {
    try {
      _logger.info('回复工单: $ticketId');
      
      await sdk.XBoardSDK.replyTicket(
        id: ticketId,
        message: message,
      );
      
      _logger.info('工单回复成功');
      return Result.success(null);
      
    } on XBoardException catch (e) {
      _logger.info('回复工单失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('回复工单异常: $e');
      return Result.failure(
        XBoardException(
          code: 'REPLY_TICKET_ERROR',
          message: '回复工单失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<void>> closeTicket(int ticketId) async {
    try {
      _logger.info('关闭工单: $ticketId');
      
      await sdk.XBoardSDK.closeTicket(ticketId);
      
      _logger.info('工单关闭成功');
      return Result.success(null);
      
    } on XBoardException catch (e) {
      _logger.info('关闭工单失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('关闭工单异常: $e');
      return Result.failure(
        XBoardException(
          code: 'CLOSE_TICKET_ERROR',
          message: '关闭工单失败: $e',
        ),
      );
    }
  }

  // ========== 私有方法：数据转换 ==========

  DomainTicket _mapToDomain(xb_sdk.Ticket sdkTicket) {
    return DomainTicket(
      id: sdkTicket.id,
      subject: sdkTicket.subject,
      priority: sdkTicket.level,
      status: TicketStatus.fromCode(sdkTicket.status),
      messages: [],  // 简单列表不包含消息
      createdAt: sdkTicket.createdAt ?? DateTime.now(),
      updatedAt: sdkTicket.updatedAt,
      closedAt: null,  // Ticket 模型没有 closedAt 字段
    );
  }

  DomainTicket _mapDetailToDomain(xb_sdk.TicketDetail sdkTicket) {
    final messages = (sdkTicket.messages ?? []).map((msg) {
      return TicketMessage(
        id: msg.id,
        content: msg.message,
        isFromUser: msg.isMe == true,
        createdAt: msg.createdAt ?? DateTime.now(),
      );
    }).toList();

    return DomainTicket(
      id: sdkTicket.id,
      subject: sdkTicket.subject,
      priority: sdkTicket.level,
      status: TicketStatus.fromCode(sdkTicket.status),
      messages: messages,
      createdAt: sdkTicket.createdAt ?? DateTime.now(),
      updatedAt: sdkTicket.updatedAt,
      closedAt: null,  // TicketDetail 模型没有 closedAt 字段
    );
  }
}
