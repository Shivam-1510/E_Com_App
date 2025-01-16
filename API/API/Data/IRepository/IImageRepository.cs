namespace API.Data.IRepository
{
    public interface IImageRepository
    {
        public string SaveImage(byte[] imageFile);
        public string GetImage(string url);
        public string UpdateImage(string url , byte[] imaageFile);

    }
}


