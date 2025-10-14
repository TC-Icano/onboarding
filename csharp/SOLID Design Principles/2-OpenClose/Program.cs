using OpenClose;

var employeeFullTime = new EmployeeFullTime("Pepito Pérez", 160);
employeeFullTime.CalculateSalaryMonthly();

var employeePartTime = new EmployeePartTime("Manuel Lopera", 180);
employeePartTime.CalculateSalaryMonthly();


Console.WriteLine("Press any key to finish...");
Console.ReadKey();