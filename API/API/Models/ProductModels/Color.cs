using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace API.Models.ProductModels
{
    public class Color
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        [Key]
        public string ColorCode { get; set; }

        [Required]
        [StringLength(50, MinimumLength = 3)]
        public string ColorName { get; set; }
    }
}
