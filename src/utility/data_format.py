

# FROM STUDIO DATA FORMAT
"""
    {
            "task_uuid": "GJNSJN-GJ345-JGFIWA",
            "upper_text": "{script_name} : {line_count}",
            "lower_text": "Workspace:  {game_name}",

            "large_icon": "robloxstudioicon",
            "small_icon": "robloxstudioicon",
        }
"""

# TO STUDIO DATA FORMAT
"""
    # AVAILABLE SUBSITUTIONS
        {task_uuid} = Task UUIDs to reset the timer for specific tasks
        {script_name} = Currently Editing Script Name
        {script_path} = Current Editing Script Path
        {line_count} = Total Line Count (exclude empty) of editing script
        {game_name} = Current Opened Game Name

    # FORMATTER
        {
            "task_uuid": "{task_uuid}",
            "upper_text": "{script_name} : {line_count}",
            "lower_text": "Workspace:  {game_name}",
            "large_icon": "robloxstudioicon",
            "small_icon": "robloxstudioicon",
        }
"""