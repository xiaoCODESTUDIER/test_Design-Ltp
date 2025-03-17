namespace testDesign.Models
{
    public class classModel
    {
        public int id { get; set; }
        public string title { get; set; } = string.Empty;
        public string content { get; set; } = string.Empty;
        public double x { get; set; }
        public double y { get; set; }
        public int eyes { get; set; }
        public string goodsid { get; set; } = string.Empty;
        public int goodsnum { get; set; }
        public int badsnum { get; set; }
        public List<goodModel> goods { get; set; } = new List<goodModel>();
        public int contentsnum { get; set; }
        public string useid { get; set; } = string.Empty;
        public string contentid { get; set; } = string.Empty;
        public List<contentModel> contents { get; set; } = new List<contentModel>();
    }
}
