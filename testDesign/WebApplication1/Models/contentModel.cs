namespace testDesign.Models
{
    public class contentModel
    {
        public int id { get; set; }
        public string contentid { get; set; } = string.Empty;
        public string Useid { get; set; } = string.Empty;
        public string Commnet { get; set; } = string.Empty;
        public DateTime CommentDate { get; set; }
        public string goodsid { get; set; } = string.Empty;
        public List<goodModel> goods { get; set; } = new List<goodModel>();
    }
}
