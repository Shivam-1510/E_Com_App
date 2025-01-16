using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using API.Models.UserModels;

namespace API.Models.ProductModels
{
    public class Product
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Key]
        public string ProductCode { get; set; }

        [Required]
        [StringLength(50, MinimumLength = 3)]
        public string ProductName { get; set; }
        public string ProductHighLights { get; set; }

        [Required]
        public string ProductDescription { get; set; }

        [Required]
        public string CategoryCode { get; set; }
        public Category Category { get; set; }

        [Required]
        public string BrandCode { get; set; }
        public Brand Brand { get; set; }

        [Required]
        public double ProductPrice { get; set; }

        [Required]
        public string FirstImage { get; set; }

        [Required]
        public string SecondImage { get; set; }

        [Required]
        public string ThirdImage { get; set; }

        public int StockCount {  get; set; }

        [Required]
        public string UserCode { get; set; }
        public User User { get; set; }

        public bool ProductStatus { get; set; }


    }
}
