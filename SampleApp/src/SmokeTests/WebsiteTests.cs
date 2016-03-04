using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using System.Net.Http;

using Xunit;

namespace SmokeTests
{
    // This project can output the Class library as a NuGet Package.
    // To enable this option, right-click on the project and select the Properties menu item. In the Build tab select "Produce outputs on build".
    public class WebsiteTests
    {
        [Fact]
        public async Task PassingTest()
        {
            using (var client = new HttpClient())
            {
                var response = await client.GetStringAsync("http://localhost/");

                Assert.Equal("Exploring ASP.NET Core with AWS.", response);
            }
        }
    }
}
