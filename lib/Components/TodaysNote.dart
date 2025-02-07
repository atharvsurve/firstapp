import 'package:flutter/material.dart';

class Todaysnote extends StatelessWidget {
  const Todaysnote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Color(0xFF31363F), // Background color of the box
        border: Border.all(
          color: Color(0xFFEEEEEE), // Border color
          width: 0.4,
        ),
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      padding: EdgeInsets.all(16), // Inner spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Icon(
                Icons.assignment, // Icon for "Quote of the Day"
                color: Colors.white, // Icon color
                size: 24, // Icon size
              ),
              SizedBox(width: 8), // Spacing between icon and text
              Text(
                "Quote of the Day",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16), // Spacing between header and quote
          // Quote text
          Text(
            """Do not save what is left after spending, but spend what is left after saving" — Warren Buffett""",
            style: TextStyle(
              color: Colors.white, // Text color
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5, // Line height for better readability
            ),
          ),
          SizedBox(height: 12), // Spacing between quote and author
          // Author text (aligned to the right)
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "— Warren Buffett",
              style: TextStyle(
                color:
                    Colors.white.withOpacity(0.8), // Slightly transparent text
                fontSize: 12,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
