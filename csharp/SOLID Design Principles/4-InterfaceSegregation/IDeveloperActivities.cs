using InterfaceSegregation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace _4_InterfaceSegregation
{
    public interface IDeveloperActivities : IActivities
    {
        //Here we can add more developer specific activities in future if required
    }
}
