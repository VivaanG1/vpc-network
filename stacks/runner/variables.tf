variable "github_runner_repos" {
  description = "Map of repository URLs and their corresponding GitHub runner tokens"
  type        = map(map(string))
  default = {
    test = {
      "https://github.com/bbc/sdp-infrastructure"           = "AEHKRMM5NT2Z3ANUMEDHKULE4TRVE"
      "https://github.com/bbc/sdp-transformations"          = "AEHKRMIDFHPLV7FILZNE2I3E4TR52"
    },
    live = {
      // Add more live repositories and tokens here
    }
  }
}