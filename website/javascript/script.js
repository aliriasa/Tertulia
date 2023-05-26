var conversations = [
  [
    {
      user: {
        name: "EmilyJohnson",
        image: "../images/user_name.png"
      },
      root: true, 
      messages: [
        "Censorship plays a vital role in protecting society by preventing the dissemination of harmful and dangerous content. In an increasingly interconnected world, where information flows freely and quickly, it becomes imperative to have measures in place to safeguard individuals and maintain social harmony. Censorship serves as a shield against offensive and morally objectionable material that can negatively impact vulnerable populations and incite violence. By filtering out such content, we create a safer environment for everyone."
      ]
    },
    {
      user: {
        name: "DavidSmith",
        image: "../images/user_name.png"
      },
      root: false, 
      messages: [
        "While the intention behind censorship may be well-meaning, it often leads to the suppression of free speech. The concept of protecting society through censorship can be subjective and easily misused. When we allow censorship in the name of protection, we risk limiting important discussions and hindering societal progress. It is essential to find a balance between protecting individuals and preserving the fundamental right to express oneself, even if the opinions expressed are controversial or uncomfortable."
      ]
    },
    {
      user: {
        name: "SophiaBrown",
        image: "../images/user_name.png"
      },
      root: false, 
      messages: [
        "I understand the concerns about potential abuses of censorship, but we must acknowledge that in certain cases, it is justified. Censorship can be necessary to prevent the dissemination of harmful and misleading information that can have severe consequences. In today's digital age, misinformation spreads rapidly, influencing public opinion, and posing threats to public health, democracy, and social cohesion. By implementing responsible and transparent censorship measures, we can protect society from the damaging effects of false information while still valuing freedom of expression."
      ]
    }
  ],
  [
    {
      user: {
        name: "OliverTaylor",
        image: "../images/user_name.png"
      },
      root: true,
      messages: [
        "Censorship undermines individual freedoms and the right to express oneself. In a democratic society, everyone should have the freedom to voice their opinions, even if they are controversial. By allowing censorship in the name of protecting society, we risk sacrificing the very essence of democracy and slipping into an authoritarian regime that stifles dissent and limits personal autonomy."
      ]
    },
    {
      user: {
        name: "IsabellaAnderson",
        image: "../images/user_name.png"
      },
      root: false,
      messages: [
        "While freedom of expression is a fundamental right, it is essential to recognize that speech can have harmful consequences. Censorship can be justified when it comes to curbing hate speech, incitement to violence, or the dissemination of dangerous ideologies. By setting certain limits on speech, we protect marginalized communities, maintain social cohesion, and prevent the spread of harmful beliefs that can jeopardize the safety and well-being of individuals within society."
      ]
    },
    {
      user: {
        name: "EthicalBalancing789",
        image: "../images/user_name.png"
      },
      root:false,
      messages: [
        "I understand the concerns about the potential abuse of censorship, but it is important to approach it with a balanced perspective. Instead of an outright rejection or acceptance of censorship, we should focus on responsible regulation. By involving diverse stakeholders, promoting transparency, and ensuring accountability, we can strike a balance between protecting society and preserving individual freedoms. Open dialogue and constructive engagement can help us navigate the complexities of censorship and minimize the risks associated with its misuse."
      ]
    }
  ]
];

var currentIndex = 0;
var textDisplay = document.getElementById("text-display");
var prevButton = document.getElementById("prev-button");
var nextButton = document.getElementById("next-button");

// Function to update the displayed conversation
function updateConversation() {
    console.log(conversations);
    var currentConversation = conversations[currentIndex];
  
    // Clear previous conversation
    textDisplay.innerHTML = "";
  
    currentConversation.forEach(function (message, index) {
      var userContainer = document.createElement("div");
      userContainer.classList.add("user-container");
  
      if (index > 0 && !message.root) {
        userContainer.classList.add("tabulated");
      } else {
        userContainer.classList.add("root");
      }
  
      var userImage = document.createElement("img");
      userImage.src = message.user.image;
      userImage.classList.add("small-image");
      userContainer.appendChild(userImage);
  
      var userName = document.createElement("div");
      userName.textContent = message.user.name;
      userName.classList.add("user-name");
      userContainer.appendChild(userName);
  
      // Add like button
      var likeButton = document.createElement("img");
      likeButton.classList.add("like-button");
      likeButton.src = "../images/not_like.png";

      // Add click event listener to the button
      likeButton.addEventListener("click", function() {
            likeButton.src = "../images/like.png";
        });

        userContainer.appendChild(likeButton);

      // Add reply button
      var replyButton = document.createElement("img");
      replyButton.src = "../images/reply.png";
      replyButton.classList.add("reply-button");
      userContainer.appendChild(replyButton);
  
      // Event handler for reply button
      replyButton.addEventListener("click", function() {
        // Handle the reply button click event here
        console.log("Reply button clicked!");
      });
  
      textDisplay.appendChild(userContainer);
  
      var messageContainer = document.createElement("div");
      messageContainer.classList.add("message-container");
  
      if (index > 0 && !message.root) {
        messageContainer.classList.add("tabulated");
      } else {
        messageContainer.classList.add("root");
      }
  
      var messageText = document.createElement("p");
      messageText.textContent = message.messages[0];
      messageContainer.appendChild(messageText);
  
      textDisplay.appendChild(messageContainer);
    });
  } 
  
  

// Function to handle next button click
function nextConversation() {
  if (currentIndex < conversations.length - 1) {
    currentIndex++;
  } else {
    currentIndex = 0;
  }
  updateConversation();
}

// Function to handle previous button click
function prevConversation() {
  if (currentIndex > 0) {
    currentIndex--;
  } else {
    currentIndex = conversations.length - 1;
  }
  updateConversation();
}

// Add event listeners to the buttons
nextButton.addEventListener("click", nextConversation);
prevButton.addEventListener("click", prevConversation);

// Initialize the conversation display
updateConversation();
