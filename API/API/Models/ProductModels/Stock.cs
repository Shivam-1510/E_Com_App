using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace API.Models.ProductModels
{
    public class Stock
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Key]
        public string StockCode { get; set; }

        [Required]
        public string ProductCode { get; set; }
        public Product Product { get; set; }

        [Required]
        public string SizeCode { get; set; }
        public Size Size { get; set; }

        [Required]
        public string ColorCode { get; set; }
        public Color Color { get; set; }

        public int StockCount { get; set; }

    
    }
}
