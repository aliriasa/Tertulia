  document.getElementById("noBtn").addEventListener("click", function() {
    window.location.href = "index.html";
  });
  
  document.getElementById("yesBtn").addEventListener("click", function() {
    document.getElementById("textEntryContainer").style.display = "block";
  });
  
  document.getElementById("submitBtn").addEventListener("click", function() {
    var newOpinion = document.getElementById("opinion").value;
    var newConversation = [
      {
        user: {
          name: "You",
          image: "../images/user_name.png"
        },
        root: true,
        messages: [newOpinion]
      }
    ];

    console.log(newConversation)

    window.location.href = "index.html";

  });

  