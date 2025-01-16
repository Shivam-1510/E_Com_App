using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace API.Models.ProductModels
{
    public class Size
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Key]
        public string SizeCode { get; set; }

        [Required]
        [StringLength(50, MinimumLength = 3)]
        public string SizeName { get; set; }

        public string SizeShortName{ get; set; }



    }
}
