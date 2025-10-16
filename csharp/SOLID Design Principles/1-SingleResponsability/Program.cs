using _1_SingleResponsability;

Console.WriteLine("Calling StudentService...");

StudentService studentService = new();
studentService.ExportAllStudentsToCsv();

Console.WriteLine("Process completed!");
Console.WriteLine("Press any key to finish...");
Console.ReadKey();
