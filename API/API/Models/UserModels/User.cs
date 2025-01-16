using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace API.Models.UserModels
{
    public class User
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Key]
        public string UserCode { get; set; }

        public string Name { get; set; }

        [Required]
        [StringLength(32)]
        public string Password { get; set; }

        [Required]
        [StringLength(10, MinimumLength = 10)]
        public string MobileNumber { get; set; }

        public bool IsMobileVerified { get; set; }

        public string EMail { get; set; }
        public string PanNumber { get; set; }
        public string Address { get; set; }

        public string PinCode { get; set; }

        public string Token { get; set; }

        public bool IsActive { get; set; }

        public DateTime CreatedOn { get; set; }

        public string CreatedBy { get; set; }

        public DateTime UpdatedOn { get; set; }

        public string UpdatedBy { get; set; }

        public DateTime LastLogin { get; set;}

    }

    public class UserInClaimVM
    {
        public User User { get; set; }
        public List<UserRole> UserRoles { get; set; }

    }

}
