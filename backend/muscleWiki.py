"""
Scraper for musclewiki.com exercise data.

Usage:
    python muscleWiki.py

Outputs to backend/data/:
    workout-data.json       — full exercise dataset
    workout-attributes.json — available filter options (categories, difficulties, etc.)
"""

import json
import os
import requests
from bs4 import BeautifulSoup

DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
os.makedirs(DATA_DIR, exist_ok=True)


def muscleList(string):
    words = string.split(' ')
    new_list = []
    i = 0
    while i < len(words):
        if words[i] == 'Lower' and i + 1 < len(words) and words[i + 1] == 'back':
            new_list.append('Lower back')
            i += 2
        elif words[i] == 'Traps' and i + 1 < len(words) and words[i + 1] == '(mid-back)':
            new_list.append('Mid back')
            i += 2
        elif words[i] == '(mid-back)':
            new_list.append('Mid back')
            i += 1
        else:
            new_list.append(words[i])
            i += 1
    return new_list


def html_table_to_json(table, row_json):
    for row in table.find_all('tr'):
        td = row.find_all('td')
        if td:
            row_json[td[0].text] = td[1].text


def getSteps(step_list):
    return [step.text for step in step_list.find_all('li')]


def getVideos(video_section):
    return [
        tag['src']
        for tag in video_section.find_all('video', {'class': 'workout-img'})
    ]


def get_exercise_data(exercise_url, exercise_json):
    response = requests.get(exercise_url)
    soup = BeautifulSoup(response.text, 'html.parser')

    videos_html = soup.find(class_='exercise-images-grid')
    exercise_json['videoURL'] = getVideos(videos_html)

    steps_html = soup.find(class_='steps-list')
    exercise_json['steps'] = getSteps(steps_html)

    table1 = soup.find('table', {'class': 'table wikitable wikimb'})
    html_table_to_json(table1, exercise_json)

    table2 = soup.find('table', {'class': 'table wikitable wikimb', 'title': 'Muscles  Targeted'})
    exercise_json['target'] = {}
    html_table_to_json(table2, exercise_json['target'])

    for tier in ('Primary', 'Secondary', 'Tertiary'):
        if tier in exercise_json['target']:
            exercise_json['target'][tier] = muscleList(exercise_json['target'][tier])

    youtube_html = soup.find(class_='long-form-video')
    if youtube_html:
        iframe = youtube_html.find('iframe', {'title': 'YouTube video player'})
        exercise_json['youtubeURL'] = iframe['src'] if iframe else ''
    else:
        exercise_json['youtubeURL'] = ''

    details_html = soup.find('div', {'class': 'summernote-content'})
    if details_html:
        exercise_json['details'] = details_html.text


def get_musclewiki_data():
    url = "https://musclewiki.com/directory"
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    exercises = soup.find_all('table', class_='wikitable')
    musclewiki_data = []
    count = 0

    for exercise in exercises:
        for row in exercise.find_all('tr')[1:]:
            columns = row.find_all('td')
            exercise_name = columns[0].find('a').text.strip()
            video_links = columns[1].find_all('a')

            print(f'{count}) Fetching {exercise_name}')
            exercise_json = {'id': count, 'exercise_name': exercise_name}
            get_exercise_data('https://musclewiki.com' + video_links[0]['href'], exercise_json)
            musclewiki_data.append(exercise_json)
            count += 1

    # Build attribute index
    categories, difficulties, forces, muscles = {}, {}, {}, {}
    for workout in musclewiki_data:
        categories[workout.get('Category', '')] = 1
        if 'Difficulty' in workout:
            difficulties[workout['Difficulty']] = 1
        if 'Force' in workout:
            forces[workout['Force']] = 1
        for tier in ('Primary', 'Secondary', 'Tertiary'):
            for muscle in workout.get('target', {}).get(tier, []):
                muscles[muscle] = 1

    workout_attributes = {
        'categories': list(categories.keys()),
        'difficulties': list(difficulties.keys()),
        'forces': list(forces.keys()),
        'muscles': list(muscles.keys()),
    }

    attrs_path = os.path.join(DATA_DIR, 'workout-attributes.json')
    data_path = os.path.join(DATA_DIR, 'workout-data.json')

    with open(attrs_path, 'w') as f:
        json.dump(workout_attributes, f, indent=4)
    print(f'Wrote {attrs_path}')

    with open(data_path, 'w') as f:
        json.dump(musclewiki_data, f, indent=4)
    print(f'Wrote {data_path} ({count} exercises)')


if __name__ == '__main__':
    get_musclewiki_data()
