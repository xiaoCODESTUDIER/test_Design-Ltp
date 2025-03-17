namespace testDesign.Models
{
    public class NotificationModel
    {
        public int Id { get; set; }
        public int PostId { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public bool IsRead { get; set; } = false;
        public DateTime CreatedAt { get; set; }
    }
}
