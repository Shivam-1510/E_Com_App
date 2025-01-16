using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace API.Models.ProductModels
{
    public class Category
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Key]
        public string CategoryCode { get; set; }

        [Required]
        [StringLength(50, MinimumLength = 3)]
        public string CategoryName { get; set; }


    }
}
