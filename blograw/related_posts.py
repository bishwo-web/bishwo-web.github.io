import os
import pandas as pd
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def generate_similarity_matrix():
    # This finds the directory where the script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    posts_dir = os.path.join(script_dir, 'posts')
    
    file_list = []
    content_list = []

    if not os.path.exists(posts_dir):
        print(f"Error: Could not find directory at {posts_dir}")
        return

    for root, dirs, files in os.walk(posts_dir):
        for file in files:
            if file.endswith('.qmd'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    text = f.read()
                    
                    # Pro-tip: Remove YAML header to improve similarity accuracy
                    # This removes everything between the first two '---' markers
                    clean_text = re.sub(r'^---.*?---', '', text, flags=re.DOTALL)
                    
                    content_list.append(clean_text)
                    file_list.append(file)

    if not content_list:
        print(f"Still no .qmd files found in {posts_dir}")
        return

    # Using the Unicode-friendly pattern for Bangla
    vectorizer = TfidfVectorizer(token_pattern=r"(?u)\b\w\w+\b")
    tfidf_matrix = vectorizer.fit_transform(content_list)
    sim_matrix = cosine_similarity(tfidf_matrix)

    df = pd.DataFrame(sim_matrix, index=file_list, columns=file_list)
    
    # Save the CSV in the same folder as the script
    output_path = os.path.join(script_dir, 'related_posts.csv')
    df.to_csv(output_path)
    print(f"Done! Created similarity matrix for {len(file_list)} posts at: {output_path}")

if __name__ == "__main__":
    generate_similarity_matrix()
