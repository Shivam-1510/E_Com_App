using System.ComponentModel.DataAnnotations;

namespace API.Models.UserModels
{
    public class RegisterVM
    {
        [Required]
        public string Name { get; set; }

        [Required]
        [StringLength(32)]
        public string Password { get; set; }

        [Required]
        [StringLength(10, MinimumLength = 10)]
        public string MobileNumber { get; set; }
    }
}
