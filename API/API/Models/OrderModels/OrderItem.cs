using API.Models.ProductModels;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace API.Models.OrderModels
{
    public class OrderItem
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Key]
        public string OrderItemCode { get; set; }

        [Required]
        public string OrderCode { get; set; }
        public Order Order { get; set; }

        [Required]
        public string ProductCode { get; set; }
        public Product Product { get; set; }

        [Required]
        public string SizeCode { get; set; }
        public Size Size { get; set; }

        [Required]
        public string ColorCode { get; set; }
        public Color Color { get; set; }

        public int Count { get; set; }

    }
}
