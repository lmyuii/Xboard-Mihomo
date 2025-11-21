import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/sdk/xboard_sdk.dart' as sdk;
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart' as xb_sdk;

/// XBoard 公告仓储实现
class XBoardNoticeRepository implements NoticeRepository {
  final _logger = FileLogger('XBoardNoticeRepository');

  @override
  Future<Result<List<DomainNotice>>> getNotices() async {
    try {
      _logger.info('获取公告列表...');
      
      final notices = await sdk.XBoardSDK.getNotices();
      
      final domainNotices = notices.map(_mapToDomain).toList();
      
      _logger.info('公告列表获取成功，共 ${domainNotices.length} 条');
      return Result.success(domainNotices);
      
    } on XBoardException catch (e) {
      _logger.info('获取公告列表失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('获取公告列表异常: $e');
      return Result.failure(
        XBoardException(
          code: 'GET_NOTICES_ERROR',
          message: '获取公告列表失败: $e',
        ),
      );
    }
  }

  // ========== 私有方法：数据转换 ==========

  DomainNotice _mapToDomain(xb_sdk.Notice sdkNotice) {
    return DomainNotice(
      id: sdkNotice.id,
      title: sdkNotice.title,
      content: sdkNotice.content,
      imageUrls: sdkNotice.imgUrl != null && sdkNotice.imgUrl!.isNotEmpty
        ? [sdkNotice.imgUrl!]
        : [],
      tags: sdkNotice.tags ?? [],
      isVisible: sdkNotice.show,
      createdAt: DateTime.fromMillisecondsSinceEpoch(sdkNotice.createdAt * 1000),
      updatedAt: sdkNotice.updatedAt != null
        ? DateTime.fromMillisecondsSinceEpoch(sdkNotice.updatedAt! * 1000)
        : null,
      metadata: {
        'source': 'xboard',
      },
    );
  }
}
