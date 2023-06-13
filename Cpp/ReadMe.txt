# Notes on using the scripts

1. The scripts are written in bash, so run in bash terminal.
2. They were written specifically for Linux Ubuntu. They were not tested on Windows or Mac.
3. The scripts assume a specific file structure, for example:

```
├── fileChecker.sh
├── grader.sh
├── hw01
│   ├── student_name_assignsubmission_file_
│   │   ├── Assignment.cpp
│   │   ├── some_more.cpp
│   │   └── some_more.h
│   ├── student_name_assignsubmission_file_
│   │   ├── Assignment.cpp
├── hw02
│   ├──  student_name_assignsubmission_file_
│   │   ├── Assignment.cpp
```

4. It is recommended to run `grader.sh` in this way: `$./grader.sh |& tee ./hw#-240/output.log` to have access to the log files.
5. If you run the scripts in the recommended way, you will find additional files called `output.log` and `record.csv` inside each of the homework files.

