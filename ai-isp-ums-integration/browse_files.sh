#!/bin/bash

echo "=== AI ISP Project File Browser ==="
echo ""

while true; do
    echo "Select option:"
    echo "1. List all C files"
    echo "2. List all header files"
    echo "3. List all directories"
    echo "4. View a specific file"
    echo "5. Search for keyword"
    echo "0. Exit"
    echo ""
    echo -n "Choice: "
    read choice
    
    case $choice in
        1)
            echo -e "\n--- C Source Files ---"
            find . -name "*.c" -type f 2>/dev/null | sort
            echo ""
            ;;
        2)
            echo -e "\n--- Header Files ---"
            find . -name "*.h" -type f 2>/dev/null | sort
            echo ""
            ;;
        3)
            echo -e "\n--- Directories ---"
            find . -type d | grep -v "^\.$" | sort
            echo ""
            ;;
        4)
            echo -n "Enter filename to view: "
            read filename
            if [ -f "$filename" ]; then
                less "$filename"
            else
                echo "File not found: $filename"
            fi
            echo ""
            ;;
        5)
            echo -n "Enter search keyword: "
            read keyword
            echo -e "\n--- Search Results ---"
            grep -r "$keyword" --include="*.c" --include="*.h" . 2>/dev/null | head -20
            echo ""
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done
