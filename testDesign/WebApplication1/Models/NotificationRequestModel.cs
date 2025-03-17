namespace testDesign.Models
{
    public class NotificationRequestModel
    {
        public int Id { get; set; }
        public int PostId { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string Comment { get; set; } = string.Empty;
    }
}
