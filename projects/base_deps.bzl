load("@integration//rules/utils:repo.bzl", "agibot_repo", "empty_json")

def base_deps():
    empty_json(
        name = "override",
    )

    agibot_repo(
        name = "agibot_repo_loader",
    )
