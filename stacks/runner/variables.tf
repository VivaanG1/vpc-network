variable "github_runner_repos" {
  description = "Map of repository URLs and their corresponding GitHub runner tokens"
  type        = map(map(string))
  default = {
    test = {
      "https://github.com/VivaanG1/vpc-network" = "A7MYWEU4EMESTGHNTHDNT5DE443ZO"
      "https://github.com/VivaanG1/route53"     = "A7MYWET7VD7RCL5TAVA5XSDE4436Q"
    },
    live = {
      // Add more live repositories and tokens here
    }
  }
}