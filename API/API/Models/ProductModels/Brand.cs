using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace API.Models.ProductModels
{
    public class Brand
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Key]
        public string BrandCode { get; set; }

        [Required]
        [StringLength(50, MinimumLength = 3)]
        public string BrandName { get; set; }

        public string BrandDetails { get; set; }

    }
}
