using API.Models.UserModels;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using API.Models.ProductModels;

namespace API.Models.OrderModels
{
    public class Cart
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Key]
        public string CartCode { get; set; }

        [Required]
        public string ProductCode { get; set; }
        public Product Product { get; set; }

        [Required]
        public string SizeCode { get; set; }
        public Size Size { get; set; }

        [Required]
        public string ColorCode { get; set; }
        public Color Color { get; set; }

        [Required]
        public string UserCode { get; set; }
        public User User { get; set; }

        [Required]
        public int Count { get; set; }

        public DateTime IntiatedAt { get; set; }

    }

}
