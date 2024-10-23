actions = [
    ("","workspace"),
    ("SHIFT","movetoworkspace"),
    ("CONTROL","movetoworkspacesilent")
]
# 10 workspaces
for i in range(0,10):
    for j in actions:
        print(f"bind=$mod {j[0]} , {i} , {j[1]} , {i} ")
