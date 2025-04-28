#!/bin/bash

# Student Management System (SMS)

#DESCRIPTION:
#A command-line program written in Bash scripting.
#Designed for a single teacher to manage up to 20 students.
#Allows adding and updating student records.
#Enables viewing detailed student information.
#Supports grade calculation and report generation



#File path 
STUDENT_FILE="student_data.txt"
TEACHER_CREDENTIALS="teacher_credentials.txt"
STUDENT_CREDENTIALS="student_credentials.txt"


# FAST's grading criteria
GRADE_A_MIN=86
GRADE_A_MINUS_MIN=82
GRADE_B_PLUS_MIN=78
GRADE_B_MIN=74
GRADE_B_MINUS_MIN=70
GRADE_C_PLUS_MIN=66
GRADE_C_MIN=62
GRADE_C_MINUS_MIN=58
GRADE_D_PLUS_MIN=54
GRADE_D_MIN=50
GRADE_F_MAX=49

# function to create files if no file exist
InitializeSystem() {
    
    if [ ! -f "$STUDENT_FILE" ]; then
        touch "$STUDENT_FILE"
    fi

    if [ ! -f "$TEACHER_CREDENTIALS" ]; then
        echo "teacher:password" > "$TEACHER_CREDENTIALS"
        echo "Teacher credentials created with default username 'teacher' and password 'password'"
    fi

    if [ ! -f "$STUDENT_CREDENTIALS" ]; then
        touch "$STUDENT_CREDENTIALS"
    fi
}

# clear screen function
ClearScreen() {
    clear
}

# display header function
DisplayHeader() {
    ClearScreen
    echo 
    echo "             STUDENT MANAGEMENT SYSTEM (SMS)           "
    echo
}

#  display teacher menu function
DisplayTeacherMenu() {
    DisplayHeader
    echo "1. Add Student"
    echo "2. Delete Student"
    echo "3. Assign Marks"
    echo "4. Calculate Grades"
    echo "5. Calculate CGPA"
    echo "6. List Passed Students"
    echo "7. List Failed Students"
    echo "8. View Student Details"
    echo "9. List All Students (Ascending by CGPA)"
    echo "10. List All Students (Descending by CGPA)"
    echo "11. Update Student Information"
    echo "12. Exit"
    echo
    echo -n "Enter your choice (1-12): "
}

#  display student menu function
DisplayStudentMenu() {
    local student_id=$1
    DisplayHeader
    echo "Student ID: $student_id"
    echo
    echo "1. View Grades"
    echo "2. View CGPA"
    echo "3. Logout"
    echo
    echo -n "Enter your choice (1-3): "
}

#  function to check if student with given roll number exists 
StudentExists() {
    local roll_no=$1
    grep -q "^$roll_no:" "$STUDENT_FILE"
    return $?
}

# add student function
AddStudent() {
    DisplayHeader
    echo "Add Student"
    echo 
    
    
    local student_count=$(wc -l < "$STUDENT_FILE")
    if [ "$student_count" -ge 20 ]; then
        echo "Maximum limit of 20 students reached. Cannot add more students."
        read -p "Press Enter to continue..."
        return
    fi
    
    
    read -p "Enter Roll Number: " roll_no
    
    if StudentExists "$roll_no"; then
        echo "Student with Roll Number $roll_no already exists."
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter Student Name: " name
    
    echo "$roll_no:$name:0:F:0.0" >> "$STUDENT_FILE"
    
    echo "$roll_no:$roll_no" >> "$STUDENT_CREDENTIALS"
    
    echo "Student added successfully."
    read -p "Press Enter to continue..."
}

# delete student function
DeleteStudent() {
    DisplayHeader
    echo "Delete Student"
    echo
    
    read -p "Enter Roll Number of the student to delete: " roll_no
    
    if ! StudentExists "$roll_no"; then
        echo "Student with Roll Number $roll_no does not exist."
        read -p "Press Enter to continue..."
        return
    fi
    
    grep -v "^$roll_no:" "$STUDENT_FILE" > temp.txt
    mv temp.txt "$STUDENT_FILE"
    
    grep -v "^$roll_no:" "$STUDENT_CREDENTIALS" > temp.txt
    mv temp.txt "$STUDENT_CREDENTIALS"
    
    echo "Student deleted successfully."
    read -p "Press Enter to continue..."
}

# assign marks to student function
AssignMarks() {
    DisplayHeader
    echo "Assign Marks"
    echo

    read -p "Enter Roll Number of the student: " roll_no

    if ! StudentExists "$roll_no"; then
        echo "Student with Roll Number $roll_no does not exist."
        read -p "Press Enter to continue..."
        return
    fi

    read -p "Enter Marks (out of 100): " marks

    if ! [[ "$marks" =~ ^[0-9]+$ ]] || [ "$marks" -lt 0 ] || [ "$marks" -gt 100 ]; then
        echo "Invalid marks. Please enter a value between 0 and 100."
        read -p "Press Enter to continue..."
        return
    fi


    local student_record=$(grep "^$roll_no:" "$STUDENT_FILE")
    local name=$(echo "$student_record" | cut -d ':' -f 2)

   
    local grade=$(CalculateGrade "$marks")

    sed -i "s/^$roll_no:$name:[0-9]*:[A-F+-]*:[0-9.]*/$roll_no:$name:$marks:$grade:0.0/" "$STUDENT_FILE"

    echo "Marks assigned successfully."
    read -p "Press Enter to continue..."
}

# calculate grade based on marks function
CalculateGrade() {
    local marks=$1
    
    if [ "$marks" -ge "$GRADE_A_MIN" ]; then
        echo "A"
    elif [ "$marks" -ge "$GRADE_A_MINUS_MIN" ]; then
        echo "A-"
    elif [ "$marks" -ge "$GRADE_B_PLUS_MIN" ]; then
        echo "B+"
    elif [ "$marks" -ge "$GRADE_B_MIN" ]; then
        echo "B"
    elif [ "$marks" -ge "$GRADE_B_MINUS_MIN" ]; then
        echo "B-"
    elif [ "$marks" -ge "$GRADE_C_PLUS_MIN" ]; then
        echo "C+"
    elif [ "$marks" -ge "$GRADE_C_MIN" ]; then
        echo "C"
    elif [ "$marks" -ge "$GRADE_C_MINUS_MIN" ]; then
        echo "C-"
    elif [ "$marks" -ge "$GRADE_D_PLUS_MIN" ]; then
        echo "D+"
    elif [ "$marks" -ge "$GRADE_D_MIN" ]; then
        echo "D"
    else
        echo "F"
    fi
}
CalculateGrades() {
    DisplayHeader
    echo "Calculate Grades"
    echo

    if [ ! -s "$STUDENT_FILE" ]; then
        echo "No students in the system."
        read -p "Press Enter to continue..."
        return
    fi

    temp_file=$(mktemp)

    while IFS=: read -r roll_no name marks grade cgpa; do
       
        if [[ "$marks" =~ ^[0-9]+$ ]]; then
            new_grade=$(CalculateGrade "$marks")
        else
            new_grade="F"
        fi

      
        echo "$roll_no:$name:$marks:$new_grade:$cgpa" >> "$temp_file"
    done < "$STUDENT_FILE"

    mv "$temp_file" "$STUDENT_FILE"

    echo "Grades calculated successfully for all students."
    read -p "Press Enter to continue..."
}
# grade to gpa converter function
GradeToGpa() {
    local grade=$1
    
    case "$grade" in
        "A")  echo "4.0" ;;
        "A-") echo "3.7" ;;
        "B+") echo "3.3" ;;
        "B")  echo "3.0" ;;
        "B-") echo "2.7" ;;
        "C+") echo "2.3" ;;
        "C")  echo "2.0" ;;
        "C-") echo "1.7" ;;
        "D+") echo "1.3" ;;
        "D")  echo "1.0" ;;
        "F")  echo "0.0" ;;
        *)    echo "0.0" ;;
    esac
}

# calculate cgpa function
CalculateCgpa() {
    DisplayHeader
    echo "Calculate CGPA"
    echo

    if [ ! -s "$STUDENT_FILE" ]; then
        echo "No students in the system."
        read -p "Press Enter to continue..."
        return
    fi

    temp_file=$(mktemp)

    while IFS=: read -r roll_no name marks grade cgpa; do
       
        echo "Converting grade '$grade' to GPA"  

        gpa=$(GradeToGpa "$grade") 
        
        echo "Processed Roll No: $roll_no, Grade: $grade, GPA: $gpa" 

       
        if [[ "$cgpa" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
           
            new_cgpa=$(echo "scale=2; ($cgpa + $gpa) / 2" | bc)
            echo "New CGPA (Rolling Average): $new_cgpa" 
        else
           
            new_cgpa=$gpa
            echo "First time CGPA: $new_cgpa"  
        fi

       
        echo "$roll_no:$name:$marks:$grade:$new_cgpa" >> "$temp_file"
    done < "$STUDENT_FILE"

    mv "$temp_file" "$STUDENT_FILE"

    echo "CGPA calculated successfully for all students."
    read -p "Press Enter to continue..."
}




# list passed students function
ListPassedStudents() {
    DisplayHeader
    echo "List of Passed Students (CGPA >= 1.0)"
    echo "------------------------------------------------------"
    echo "Roll No | Name                 | Marks | Grade | CGPA"
    echo "------------------------------------------------------"
    
    
    if [ ! -s "$STUDENT_FILE" ]; then
        echo "No students in the system."
        read -p "Press Enter to continue..."
        return
    fi
    
   
    local found=0
    while IFS=: read -r roll_no name marks grade cgpa; do
        if (( $(echo "$cgpa >= 1.0" | bc -l) )); then
            printf "%-8s| %-21s| %-6s| %-6s| %-4s\n" "$roll_no" "$name" "$marks" "$grade" "$cgpa"
            found=1
        fi
    done < "$STUDENT_FILE"
    
    if [ "$found" -eq 0 ]; then
        echo "No passed students found."
    fi
    
    read -p "Press Enter to continue..."
}

# list failed students function
ListFailedStudents() {
    DisplayHeader
    echo "List of Failed Students (CGPA < 1.0)"
    echo "------------------------------------------------------"
    echo "Roll No | Name                 | Marks | Grade | CGPA"
    echo "------------------------------------------------------"
    
    if [ ! -s "$STUDENT_FILE" ]; then
        echo "No students in the system."
        read -p "Press Enter to continue..."
        return
    fi
    
    local found=0
    while IFS=: read -r roll_no name marks grade cgpa; do
        if (( $(echo "$cgpa < 1.0" | bc -l) )); then
            printf "%-8s| %-21s| %-6s| %-6s| %-4s\n" "$roll_no" "$name" "$marks" "$grade" "$cgpa"
            found=1
        fi
    done < "$STUDENT_FILE"
    
    if [ "$found" -eq 0 ]; then
        echo "No failed students found."
    fi
    
    read -p "Press Enter to continue..."
}

# view a specific student's details function
ViewStudentDetails() {
    DisplayHeader
    echo "View Student Details"
    echo
    
    read -p "Enter Roll Number of the student: " roll_no
    
   
    if ! StudentExists "$roll_no"; then
        echo "Student with Roll Number $roll_no does not exist."
        read -p "Press Enter to continue..."
        return
    fi
    
   
    echo "Student Details:"
    echo "------------------------------------------------------"
    echo "Roll No | Name                 | Marks | Grade | CGPA"
    echo "------------------------------------------------------"
    
    local student_record=$(grep "^$roll_no:" "$STUDENT_FILE")
    local name=$(echo "$student_record" | cut -d ':' -f 2)
    local marks=$(echo "$student_record" | cut -d ':' -f 3)
    local grade=$(echo "$student_record" | cut -d ':' -f 4)
    local cgpa=$(echo "$student_record" | cut -d ':' -f 5)
    
    printf "%-8s| %-21s| %-6s| %-6s| %-4s\n" "$roll_no" "$name" "$marks" "$grade" "$cgpa"
    
    read -p "Press Enter to continue..."
}

# function of students sorted by CGPA (ascending)
ListStudentsAscending() {
    DisplayHeader
    echo "List of All Students (Ascending by CGPA)"
    echo "------------------------------------------------------"
    echo "Roll No | Name                 | Marks | Grade | CGPA"
    echo "------------------------------------------------------"
    
   
    if [ ! -s "$STUDENT_FILE" ]; then
        echo "No students in the system."
        read -p "Press Enter to continue..."
        return
    fi
    
    
    sort -t ':' -k 5 -n "$STUDENT_FILE" | while IFS=: read -r roll_no name marks grade cgpa; do
        printf "%-8s| %-21s| %-6s| %-6s| %-4s\n" "$roll_no" "$name" "$marks" "$grade" "$cgpa"
    done
    
    read -p "Press Enter to continue..."
}

# function of students sorted by CGPA (descending)
ListStudentsDescending() {
    DisplayHeader
    echo "List of All Students (Descending by CGPA)"
    echo "------------------------------------------------------"
    echo "Roll No | Name                 | Marks | Grade | CGPA"
    echo "------------------------------------------------------"
    
    
    if [ ! -s "$STUDENT_FILE" ]; then
        echo "No students in the system."
        read -p "Press Enter to continue..."
        return
    fi
    
    sort -t ':' -k 5 -nr "$STUDENT_FILE" | while IFS=: read -r roll_no name marks grade cgpa; do
        printf "%-8s| %-21s| %-6s| %-6s| %-4s\n" "$roll_no" "$name" "$marks" "$grade" "$cgpa"
    done
    
    read -p "Press Enter to continue..."
}

# update student information function
UpdateStudentInfo() {
    DisplayHeader
    echo "Update Student Information"
    echo 
    
    read -p "Enter Roll Number of the student: " roll_no
    
    
    if ! StudentExists "$roll_no"; then
        echo "Student with Roll Number $roll_no does not exist."
        read -p "Press Enter to continue..."
        return
    fi
    
    local student_record=$(grep "^$roll_no:" "$STUDENT_FILE")
    local name=$(echo "$student_record" | cut -d ':' -f 2)
    local marks=$(echo "$student_record" | cut -d ':' -f 3)
    local grade=$(echo "$student_record" | cut -d ':' -f 4)
    local cgpa=$(echo "$student_record" | cut -d ':' -f 5)
    
    echo "Current Details:"
    echo "Roll No: $roll_no"
    echo "Name: $name"
    echo "Marks: $marks"
    echo "Grade: $grade"
    echo "CGPA: $cgpa"
    echo
    
    echo "What would you like to update?"
    echo "1. Name"
    echo "2. Marks"
    echo "3. Cancel"
    read -p "Enter your choice (1-3): " choice
    
    case "$choice" in
        1)
            read -p "Enter new name: " new_name
            sed -i "s/^$roll_no:$name:$marks:$grade:$cgpa$/$roll_no:$new_name:$marks:$grade:$cgpa/" "$STUDENT_FILE"
            echo "Name updated successfully."
            ;;
        2)
            read -p "Enter new marks: " new_marks
            
            
            if ! [[ "$new_marks" =~ ^[0-9]+$ ]] || [ "$new_marks" -lt 0 ] || [ "$new_marks" -gt 100 ]; then
                echo "Invalid marks. Please enter a value between 0 and 100."
                read -p "Press Enter to continue..."
                return
            fi
            
            sed -i "s/^$roll_no:$name:$marks:$grade:$cgpa$/$roll_no:$name:$new_marks:$grade:$cgpa/" "$STUDENT_FILE"
            echo "Marks updated successfully."
            echo "Note: Please recalculate grades and CGPA from the main menu."
            ;;
        3)
            echo "Update cancelled."
            ;;
        *)
            echo "Invalid choice. Update cancelled."
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

# view grades function
ViewGrades() {
    local student_id=$1
    
    DisplayHeader
    echo "View Grades"
    
    
    echo "Your Grades:"
    
    
    local student_record=$(grep "^$student_id:" "$STUDENT_FILE")
    local name=$(echo "$student_record" | cut -d ':' -f 2)
    local marks=$(echo "$student_record" | cut -d ':' -f 3)
    local grade=$(echo "$student_record" | cut -d ':' -f 4)
    
    echo "Name: $name"
    echo "Marks: $marks"
    echo "Grade: $grade"
    
    read -p "Press Enter to continue..."
}

# view CGPA function
ViewCgpa() {
    local student_id=$1
    
    DisplayHeader
    echo "View CGPA"
    
    
    
    echo "Your CGPA:"
    echo "----------"
    
    local student_record=$(grep "^$student_id:" "$STUDENT_FILE")
    local name=$(echo "$student_record" | cut -d ':' -f 2)
    local cgpa=$(echo "$student_record" | cut -d ':' -f 5)
    
    echo "Name: $name"
    echo "CGPA: $cgpa"
    
    read -p "Press Enter to continue..."
}

#login function
TeacherLogin() {
    DisplayHeader
    echo "Teacher Login"
    echo 
    
    local username password
    read -p "Username: " username
    read -sp "Password: " password
    echo  

    echo "Debug: username=$username password=$password"

    if grep -q "^$username:$password$" "$TEACHER_CREDENTIALS"; then
        echo "Login successful."
        sleep 1
        TeacherMenu
    else
        echo "Invalid username or password."
        read -p "Press Enter to continue..."
    fi
}
# process student login function
StudentLogin() {
    DisplayHeader
    echo "Student Login"
    
    
    local roll_no password
    read -p "Roll Number: " roll_no
    read -sp "Password: " password
    echo  

    echo "Debug: roll_no=$roll_no password=$password"
    
    if grep -q "^$roll_no:$password$" "$STUDENT_CREDENTIALS"; then
        echo "Login successful."
        sleep 1
        StudentMenu "$roll_no"
    else
        echo "Invalid roll number or password."
        read -p "Press Enter to continue..."
    fi
}


#  handle teacher menu function
TeacherMenu() {
    local choice
    
    while true; do
        DisplayTeacherMenu
        read choice
        
        case "$choice" in
            1) AddStudent ;;
            2) DeleteStudent ;;
            3) AssignMarks ;;
            4) CalculateGrades ;;
            5) CalculateCgpa ;;
            6) ListPassedStudents ;;
            7) ListFailedStudents ;;
            8) ViewStudentDetails ;;
            9) ListStudentsAscending ;;
            10) ListStudentsDescending ;;
            11) UpdateStudentInfo ;;
            12) return ;;
            *) 
                echo "Invalid choice. Please try again."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# handle student menu function
StudentMenu() {
    local student_id=$1
    local choice
    
    while true; do
        DisplayStudentMenu "$student_id"
        read choice
        
        case "$choice" in
            1) ViewGrades "$student_id" ;;
            2) ViewCgpa "$student_id" ;;
            3) return ;;
            *) 
                echo "Invalid choice. Please try again."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Main function to run the system
main() {
    InitializeSystem
    
    while true; do
        DisplayHeader
        echo "1. Teacher Login"
        echo "2. Student Login"
        echo "3. Exit"
        echo
        echo -n "Enter your choice (1-3): "
        read choice
        
        case "$choice" in
            1) TeacherLogin ;;
            2) StudentLogin ;;
            3) 
                echo "Thank you for using the Student Management System."
                exit 0
                ;;
            *) 
                echo "Invalid choice. Please try again."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Start the system
main
