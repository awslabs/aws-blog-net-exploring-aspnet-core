using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using System.Net.Http;

using Xunit;

namespace SmokeTests
{
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
