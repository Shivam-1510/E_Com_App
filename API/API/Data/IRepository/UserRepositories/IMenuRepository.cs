using API.Models.Menus;

namespace API.Data.IRepository.UserRepositories
{
    public interface IMenuRepository : IRepository<Menu>
    {
        public object GetMenuWithSubmenus(Menu Menu, List<Menu> AllMenus);
    }

}
