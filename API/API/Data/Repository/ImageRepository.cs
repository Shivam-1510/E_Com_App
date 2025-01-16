using API.Data.IRepository;
using SixLabors.ImageSharp;

namespace API.Data.Repository
{
    public class ImageRepository : IImageRepository
    {
        public string SaveImage(byte[] imageFile)
        {
            try
            {
                using (MemoryStream ms = new MemoryStream(imageFile))
                {
                    using (var image = Image.Load(ms))
                    {
                        string directoryPath = "Data/ProductImages";
                        if (!Directory.Exists(directoryPath))
                            Directory.CreateDirectory(directoryPath);
                        string imagePath = Path.Combine(directoryPath, $"{Guid.NewGuid()}.png");
                        image.Save(imagePath);

                        return imagePath;
                    }

                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }
        public string GetImage(string url)
        {
            try
            {
                byte[] imageBytes = File.ReadAllBytes(url);

                string base64Image = Convert.ToBase64String(imageBytes);

                return base64Image;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }

        public string UpdateImage(string url, byte[] imageFile)
        {
            try
            {
                File.Delete(url);

                using (MemoryStream ms = new MemoryStream(imageFile))
                {
                    using (var image = Image.Load(ms))
                    {
                        string directoryPath = "Data/ProductImages";
                        if (!Directory.Exists(directoryPath))
                            Directory.CreateDirectory(directoryPath);
                        string imagePath = Path.Combine(directoryPath, $"{Guid.NewGuid()}.png");
                        image.Save(imagePath);
                        return imagePath;
                    }
                }

            }
            catch (Exception ex)
            {
                throw new Exception(ex.ToString());
            }
        }
    }
}


