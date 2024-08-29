// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Upload {
  
  // Struct to represent access control
  struct Access {
     address user;  // Address of the user
     bool access;   // Access status: true (has access) or false (no access)
  }

  // Mapping to store URLs associated with each address
  mapping(address => string[]) value;

  // Nested mapping to manage ownership permissions
  // ownership[owner][user] = true means 'user' has access to 'owner's data
  mapping(address => mapping(address => bool)) ownership;

  // Mapping to store the list of access controls for each user
  mapping(address => Access[]) accessList;

  // Nested mapping to check if there was previous data related to access control
  mapping(address => mapping(address => bool)) previousData;

  // Function to add a URL to the caller's list
  // _user: The address of the user to add the URL for
  // url: The URL string to be added
  function add(address _user, string memory url) external {
      value[_user].push(url); // Add the URL to the user's list
  }

  // Function to grant access to another user
  // user: The address of the user to grant access to
  function allow(address user) external {
      ownership[msg.sender][user] = true; // Grant access

      // Check if access has been previously granted
      if (previousData[msg.sender][user]) {
          // Update access to true if the user is found in the access list
          for (uint i = 0; i < accessList[msg.sender].length; i++) {
              if (accessList[msg.sender][i].user == user) {
                  accessList[msg.sender][i].access = true; // Set access to true
              }
          }
      } else {
          // If no previous data, add a new access entry
          accessList[msg.sender].push(Access(user, true));  // Add new access
          previousData[msg.sender][user] = true;  // Mark as having previous data
      }
  }

  // Function to revoke access from a user
  // user: The address of the user to revoke access from
  function disallow(address user) public {
      ownership[msg.sender][user] = false; // Revoke access

      // Update access to false if the user is found in the access list
      for (uint i = 0; i < accessList[msg.sender].length; i++) {
          if (accessList[msg.sender][i].user == user) { 
              accessList[msg.sender][i].access = false;  // Set access to false
          }
      }
  }

  // Function to display the list of URLs for a user
  // _user: The address of the user whose URLs are to be displayed
  // Returns: An array of URLs
  function display(address _user) external view returns(string[] memory) {
      // Check if the caller is the user or has been granted access
      require(_user == msg.sender || ownership[_user][msg.sender], "You don't have access");

      return value[_user]; // Return the list of URLs
  }

  // Function to get the list of users who have been granted access by the caller
  // Returns: An array of Access structs
  function shareAccess() public view returns(Access[] memory) {
      return accessList[msg.sender]; // Return the access list
  }
}
