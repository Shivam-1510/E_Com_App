using System.ComponentModel.DataAnnotations;

namespace API.Models.ProductModels
{
    public class ImageModel
    {
        [Required]
        public string ProductCode { get; set; }

        [Required]
        public string FirstImage { get; set; }
        public bool FirstImageStatus { get; set; }

        [Required]
        public string SecondImage { get; set; }
        public bool SecondImageStatus { get; set; }


        [Required]
        public string ThirdImage { get; set; }
        public bool ThirdImageStatus { get; set; }


    }
}
