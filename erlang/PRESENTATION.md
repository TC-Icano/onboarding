# Staff Roles API - Erlang Implementation Presentation

## Understanding of the Problem

### Scenario Overview
As a newly joined platform software developer at a healthcare technology company, I was tasked with creating a robust API to manage staff roles within healthcare organizations. The core challenge involved:

- **Healthcare Provider Needs**: Healthcare providers require efficient storage and retrieval of staff role data for multiple roles within their organizations
- **API Requirements**: Support for basic HTTP methods (GET, POST, PUT, DELETE) with JSON request/response handling
- **Data Structure**: Managing staff role information including personal details (first_name, last_name, gender, mrn, organization) and event types
- **Performance**: Ensuring efficient data operations for healthcare providers' operational needs

### Request Information
Healthcare providers need to save and retrieve data based on the multiple staff roles that exist within an organization. They need these operations to be efficient for their own operational purposes, ensuring quick access to staff information during critical healthcare scenarios.

---

## Challenges & Learnings

### Background Context
During the last years, I've been working specifically with Object-Oriented Programming (OOP) languages, and now that I've been introduced to Erlang, it seems amazing and fascinating! Starting to work with a functional programming language appears crucial, and I believe it will expand my knowledge in other paradigms and technologies.

### Challenge 1: Understanding OOP vs Functional Programming Paradigms

**Key Differences between C# (OOP) and Erlang (Functional):**

| Aspect | C# (OOP) | Erlang (Functional) |
|--------|----------|-------------------|
| **Data Mutability** | Mutable objects, state changes | Immutable data, no side effects |
| **Problem Solving** | Objects with methods and properties | Functions that transform data |
| **Error Handling** | Try-catch exception handling | Pattern matching and "let it crash" philosophy |
| **Concurrency** | Threads, locks, shared memory | Actor model with lightweight processes |
| **Code Organization** | Classes, inheritance, polymorphism | Modules, functions, pattern matching |
| **Memory Management** | Garbage collection with references | Isolated process memory, automatic cleanup |

### Challenge 2: Understanding Atoms in Erlang

**What are Atoms?**
Atoms in Erlang are constants whose name is their own value. They are remarkable because:
- They are literals, a constant with name
- Used extensively for pattern matching and message passing
- Stored in a global atom table (limited to ~1 million atoms)
- Examples: `ok`, `error`, `undefined`, `role_not_found`

**Usage in the project:**
```erlang
case execute_redis_command(["GET", Key]) of
    {ok, JsonBinary} -> process_data(JsonBinary);
    {error, Reason} -> handle_error(Reason)
end.
```

### Challenge 3: Naming Conventions and Code Style

**Differences between C# and Erlang:**
- **C#**: PascalCase for classes/methods, camelCase for variables
- **Erlang**: snake_case for modules/functions, variables start with uppercase
- **Adaptation Strategy**: As this becomes part of daily work, understanding and adapting to these conventions happens naturally through practice

### Challenge 4: Error Handling Philosophy - "Let It Crash"

**Revolutionary Approach:**
In C# we typically implement try-catch statements to prevent system crashes:
```csharp
try {
    var result = RiskyOperation();
    return result;
} catch (Exception ex) {
    // Handle error
    return default;
}
```

In Erlang, following the "let it crash" philosophy without using traditional exception handling is amazing! The supervisor trees ensure system resilience by restarting failed processes.

### Challenge 5: Pattern Matching and Function Alternatives

**Erlang's Pattern Matching:**
When implementing functions in Erlang, if input parameters don't match the expected pattern, it's fascinating to implement alternative function clauses that return default responses:

```erlang
insert_role(Role) when is_record(Role, role) ->
    %% Process valid role record
    process_role(Role);
insert_role(_) ->
    %% Handle invalid input
    {error, invalid_role_record}.
```

**C# Equivalent:**
C# doesn't have native pattern matching like Erlang (until recent versions with limited support), typically requiring explicit type checking:
```csharp
public Result InsertRole(object input)
{
    if (input is Role role)
        return ProcessRole(role);
    else
        return new Result { Error = "Invalid role record" };
}
```

---

## Design of the Solution

### Technical Architecture

The solution maintains data integrity and follows RESTful API best practices, implementing complete CRUD operations (GET, POST, PUT, DELETE). For clean code architecture, I organized the project into fundamental layers applying SOLID principles:

**Layer Structure:**
- **Handlers**: HTTP request/response management (`role_handler.erl`)
- **Services**: Business logic and orchestration (`role_service.erl`)
- **Repositories**: Data access layer (`role_repository.erl`)
- **Utils**: Helper functions and utilities (`json_utils.erl`)

### Redis Integration

**Why Redis?**
Redis usage is crucial for accessing data efficiently because:
- **In-Memory Storage**: Provides extremely fast read/write operations
- **Data Structures**: Supports various data types (strings, sets, hashes) perfect for our role management
- **Persistence**: Offers configurable persistence options for data durability
- **Scalability**: Excellent for high-throughput healthcare applications
- **Atomic Operations**: Ensures data consistency with concurrent access

**Redis Commands Used:**

| Command | Definition | Example Usage |
|---------|------------|---------------|
| **SET** | Store a key-value pair in Redis | `SET role:99991946 {"event_type":"Arrival",...}` |
| **GET** | Retrieve the value associated with a key | `GET role:99991946` returns role JSON data |
| **MGET** | Multiple data retrieval - get values for multiple keys at once | `MGET role:123 role:456 role:789` returns array of values |
| **SADD** | Add one or more members to a set | `SADD roles:all role:99991946` adds role key to the set |
| **SMEMBERS** | Get all members of a set | `SMEMBERS roles:all` returns all role keys |
| **EXISTS** | Check if a key exists in Redis | `EXISTS role:99991946` returns 1 if exists, 0 if not |
| **DEL** | Delete one or more keys | `DEL role:99991946` removes the role data |
| **SREM** | Remove one or more members from a set | `SREM roles:all role:99991946` removes key from set |

**Implementation Strategy:**
```erlang
%% Store role data with efficient key-value access
Key = generate_role_key(Role#role.data#data.mrn),
RoleJson = json_utils:role_to_json(Role),
JsonBinary = jsx:encode(RoleJson),
execute_redis_command(["SET", Key, JsonBinary])

%% Efficient bulk retrieval using MGET
execute_redis_command(["MGET" | RoleKeys])
```

**Visual Data Structure Examples:**

**SET Command - Key-Value Dictionary:**
```
Redis Key-Value Store:
┌─────────────────────┬──────────────────────────────────────────────┐
│ Key                 │ Value (JSON)                                 │
├─────────────────────┼──────────────────────────────────────────────┤
│ role:99991946       │ {"event_type":"Arrival","data":{"first_n...  │
│ role:88882035       │ {"event_type":"Departure","data":{"first... │
│ role:77773124       │ {"event_type":"Arrival","data":{"first_n... │
└─────────────────────┴──────────────────────────────────────────────┘
```

**SADD Command - Set Data Structure:**
```
Redis Set "roles:all":
┌─────────────────────────────────────────┐
│           Set: roles:all                │
├─────────────────────────────────────────┤
│  ● role:99991946                        │
│  ● role:88882035                        │
│  ● role:77773124                        │
│  ● role:55554567                        │
│  ● role:44445678                        │
└─────────────────────────────────────────┘
```

**Combined Operation Flow:**
```
1. SET role:99991946 → Stores individual role data in key-value dictionary
2. SADD roles:all role:99991946 → Adds the key to the index set

Result: Fast individual access + Fast bulk listing capability
```

### Makefile Automation

**Importance of Makefile:**
Using Makefile is essential to automate complex commands because:
- **Consistency**: Ensures all team members use identical build processes
- **Efficiency**: Single commands execute multiple complex operations
- **Documentation**: Self-documenting build processes
- **Integration**: Easy integration with CI/CD pipelines
- **Dependency Management**: Handles complex dependency chains automatically

**Common Makefile Targets:**
```makefile
compile:    # Compiles the Erlang application
test:       # Runs all test suites
clean:      # Cleans build artifacts
docker:     # Builds Docker container
run:        # Starts the application
```

### Docker Containerization

**Benefits of Dockerization:**
Dockerizing the system provides the best approach for deployment because:
- **Portability**: Applications run consistently across different environments
- **Isolation**: Prevents conflicts between applications and system dependencies
- **Scalability**: Easy horizontal scaling and load distribution
- **DevOps Integration**: Seamless CI/CD pipeline integration
- **Version Control**: Immutable application versions with rollback capabilities
- **Resource Efficiency**: Lighter than virtual machines, better resource utilization

**Healthcare Industry Benefits:**
- **Compliance**: Consistent environments aid in regulatory compliance
- **Reliability**: Critical healthcare systems require predictable deployments
- **Migration**: Easy movement between cloud providers or on-premises infrastructure

---

## Working Solution

### 🌐 Available API Endpoints

The Staff Roles API provides a comprehensive set of RESTful endpoints for managing healthcare staff role data. Below are the available endpoints with detailed examples:

---

#### 🟢 **GET** - Retrieve All Roles
**Description:** Fetches all staff roles stored in the system
```http
GET http://localhost:8080/roles
```
**Response:** Returns a JSON array containing all role records

---

#### 🟢 **GET** - Retrieve Role by MRN
**Description:** Fetches a specific staff role using Medical Record Number (MRN)
```http
GET http://localhost:8080/roles/2
```
**Parameters:**
- `mrn` (path parameter): Medical Record Number of the staff member

---

#### 🟡 **POST** - Create New Role
**Description:** Creates a new staff role record in the system
```http
POST http://localhost:8080/roles/
Content-Type: application/json
```

**Request Body:**
```json
{
    "event_type": "Arrival",
    "data": {
        "first_name": "Ráúl",
        "last_name": "Martínéz",
        "gender": "M",
        "mrn": "2",
        "organization": "GPXS87a6lEnkmzONMeR2qIVg"
    }
}
```

**Field Descriptions:**
- `event_type`: Type of event (e.g., "Arrival", "Departure")
- `first_name`: Staff member's first name
- `last_name`: Staff member's last name  
- `gender`: Gender identifier ("M", "F", etc.)
- `mrn`: Unique Medical Record Number
- `organization`: Organization identifier

---

#### 🔵 **PUT** - Update Existing Role
**Description:** Updates an existing staff role record by MRN
```http
PUT http://localhost:8080/roles/2
Content-Type: application/json
```

**Request Body:**
```json
{
    "event_type": "Arrival",
    "data": {
        "first_name": "Raúll",
        "last_name": "Martínez",
        "gender": "M",
        "mrn": "2",
        "organization": "GPXS87a6lEnkmzONMeR2qIVg"
    }
}
```

**Note:** All fields in the request body will replace the existing role data

---

#### 🔴 **DELETE** - Remove Role
**Description:** Permanently deletes a staff role record from the system
```http
DELETE http://localhost:8080/roles/2
```
**Parameters:**
- `mrn` (path parameter): Medical Record Number of the role to delete

**⚠️ Warning:** This operation is irreversible. Ensure proper authorization before deletion.

---

### 📋 Endpoint Summary Table

| Method | Endpoint | Purpose | Requires Body |
|--------|----------|---------|---------------|
| 🟢 GET | `/roles` | List all roles | ❌ No |
| 🟢 GET | `/roles/{mrn}` | Get specific role | ❌ No |
| 🟡 POST | `/roles/` | Create new role | ✅ Yes |
| 🔵 PUT | `/roles/{mrn}` | Update existing role | ✅ Yes |
| 🔴 DELETE | `/roles/{mrn}` | Delete role | ❌ No |

### 🧪 Testing Recommendations

**Tools for API Testing:**
- **Postman**: Comprehensive API testing with collections and environments
- **curl**: Command-line testing for quick verification
- **Insomnia**: Alternative REST client with intuitive interface
- **HTTPie**: Human-friendly command-line HTTP client

**Sample PowerShell Commands:**
```powershell
# Get all roles
Invoke-RestMethod -Uri "http://localhost:8080/roles" -Method GET

# Get specific role
Invoke-RestMethod -Uri "http://localhost:8080/roles/2" -Method GET

# Create new role
$body = @{
    event_type = "Arrival"
    data = @{
        first_name = "John"
        last_name = "Doe"  
        gender = "M"
        mrn = "123"
        organization = "ORG123"
    }
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri "http://localhost:8080/roles/" -Method POST -Body $body -ContentType "application/json"

# Update role
$updateBody = @{
    event_type = "Departure"
    data = @{
        first_name = "John"
        last_name = "Smith"
        gender = "M" 
        mrn = "123"
        organization = "ORG123"
    }
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri "http://localhost:8080/roles/123" -Method PUT -Body $updateBody -ContentType "application/json"

# Delete role
Invoke-RestMethod -Uri "http://localhost:8080/roles/123" -Method DELETE
```

**Alternative curl Commands (if curl is installed):**
```bash
# Get all roles
curl -X GET http://localhost:8080/roles

# Get specific role  
curl -X GET http://localhost:8080/roles/2

# Create new role
curl -X POST http://localhost:8080/roles/ -H "Content-Type: application/json" -d "{\"event_type\":\"Arrival\",\"data\":{\"first_name\":\"John\",\"last_name\":\"Doe\",\"gender\":\"M\",\"mrn\":\"123\",\"organization\":\"ORG123\"}}"

# Update role
curl -X PUT http://localhost:8080/roles/2 -H "Content-Type: application/json" -d "{\"event_type\":\"Departure\",\"data\":{\"first_name\":\"John\",\"last_name\":\"Smith\",\"gender\":\"M\",\"mrn\":\"2\",\"organization\":\"ORG123\"}}"

# Delete role
curl -X DELETE http://localhost:8080/roles/2
```

### Planned Demonstrations:
1. **API Endpoint Testing**: Live demonstrations using Postman/curl
2. **Redis Data Operations**: Showing efficient data storage and retrieval
3. **Error Handling**: Demonstrating Erlang's "let it crash" philosophy
4. **Pattern Matching**: Real-world examples of function clauses
5. **Docker Deployment**: Complete containerized solution deployment

---

## Conclusion

This project represents a significant paradigm shift from traditional OOP development to functional programming with Erlang. The healthcare domain's requirements for reliability, efficiency, and scalability align perfectly with Erlang's strengths in building fault-tolerant, concurrent systems.

The combination of Erlang's functional approach, Redis's performance, and Docker's portability creates a robust foundation for healthcare staff role management systems that can scale and adapt to various organizational needs.