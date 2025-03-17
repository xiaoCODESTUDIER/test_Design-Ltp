using Microsoft.AspNetCore.Mvc;
using testDesign.Models;
using testDesign.Services;
using WebApplication1;

namespace testDesign.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationController : ControllerBase
    {
        private readonly AppDbContext Database;
        private readonly INotificationService NotifyService;
        public NotificationController(AppDbContext context, INotificationService notification)
        {
            Database = context;
            NotifyService = notification;
        }

        // 通知帖子作者
        [HttpPost("notify")]
        public async Task<IActionResult> NotifyPostAuhtor([FromBody] NotificationRequestModel request)
        {
            if (request == null)
            {
                return BadRequest("请求体不能为空");
            }
            bool result = await NotifyService.NotifyPostAuthor(request.PostId, request.UserId, request.Comment);
            if (result)
            {
                return Ok(new { message = "通知已发送" });
            }
            else
            {
                return NotFound("帖子未找到");
            }
        }

        // 获取未读通知数量
        [HttpGet("unread-count/{userId}")]
        public async Task<IActionResult> GetUnreadNotificationCount(string userId)
        {
            var count = await NotifyService.GetUnreadNotificationCount(userId);
            return Ok(new { unreadCount = count });
        }

        // 获取通知列表
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetNotifications(string userId)
        {
            var notifications = await NotifyService.GetNotifications(userId);
            return Ok(notifications);
        }

        // 标记通知为已读
        [HttpPost("mark-read/{notificationId}")]
        public async Task<IActionResult> MarkNotificationAsRead(int notificationId)
        {
            await NotifyService.MarkNotificationAsRead(notificationId);
            return Ok(new { message = "通知已标记为已读" });
        }
    }
}
