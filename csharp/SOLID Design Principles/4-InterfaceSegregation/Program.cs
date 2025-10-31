using InterfaceSegregation;

//Invoke the functionality of the Developer class
new Developer().Develop();

//Invoke the functionality of the Tester class
new Tester().Develop();

//Invoke the functionality of the ScrumMaster class
new ScrumMaster().Plan();
new ScrumMaster().Communicate();
new ScrumMaster().Design();
new ScrumMaster().Develop();
new ScrumMaster().Test();

Console.WriteLine("Press any key to finish...");
Console.ReadKey();
