using Route = API.Models.Routes.Route;

namespace API.Data.IRepository.UserRepositories
{
    public interface IRouteRepository : IRepository<Route>
    {
        public object GetRouteWithSubRoutes(Route Route, List<Route> AllRoutes);

    }
}
