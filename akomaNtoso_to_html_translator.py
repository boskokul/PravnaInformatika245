from datetime import datetime
import os
import xml.etree.ElementTree as ET
from html import escape
import sys
from pathlib import Path


def format_date(date_str):
    try:
        
        date_str = date_str.strip()
        
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        
        formatted_date = date_obj.strftime("%d. %B %Y")
        
        months = {
            "January": "Januar", "February": "Februar", "March": "Mart", "April": "April", 
            "May": "Maj", "June": "Jun", "July": "Jul", "August": "Avgust", 
            "September": "Septembar", "October": "Oktobar", "November": "Novembar", "December": "Decembar"
        }
        month_name = date_obj.strftime("%B")
        return formatted_date.replace(month_name, months.get(month_name, month_name))
    except ValueError as e:
        print(f"Greška u formatu datuma: {date_str}")  
        print(f"Detalj greške: {e}")
        return date_str


def verdict_xml_to_html(xml_file, output_html):

    namespaces = {'akn': 'http://docs.oasis-open.org/legaldocml/ns/akn/3.0/WD17'}

  
    tree = ET.parse(xml_file)
    root = tree.getroot()

    # frbr elem
    frbr_author = root.find(".//akn:FRBRauthor", namespaces).text if root.find(".//akn:FRBRauthor", namespaces) is not None else "Nepoznat autor"
    frbr_title = root.find(".//akn:FRBRtitle", namespaces).text if root.find(".//akn:FRBRtitle", namespaces) is not None else "Naslov nije dostupan"
    frbr_date = root.find(".//akn:FRBRdate", namespaces).text if root.find(".//akn:FRBRdate", namespaces) is not None else "Datum nije dostupan"

    frbr_date = format_date(frbr_date)
    # zaglavlje
    html_content = f"""
    <!DOCTYPE html>
    <html lang='en'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>{escape(frbr_title)}</title>
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; margin: 20px; }}
            h1, h4 {{ text-align: center; margin: 0; }}
            h4 {{ color: gray; }}
            h2 {{ color: navy; text-align: left; margin-top: 20px; }}
            p {{ text-align: justify; }}
            .centered {{ text-align: center; }}
        </style>
    </head>
    <body>
        <h4>{escape(frbr_author)}</h4>
        <h1>{escape(frbr_title)}</h1>
        <h4>{escape(frbr_date)}</h4>
        <br><br>
    """

    isJudgmentBody = False

   
    for child in root.findall(".//*", namespaces):
        tag_name = child.tag.split("}")[-1]  # uklanjanje namespacea
        text = child.text.strip() if child.text else ""

        if tag_name == "judgmentBody":
            isJudgmentBody = True

        if isJudgmentBody:
        # obrada tagova
            if tag_name in {"introduction", "background", "decision", "arguments"}:
                if text:
                    html_content += f"<p>{escape(text)}</p>"
            if tag_name == "conclusion":
                if text:
                    html_content += f"<p>{escape(text)}</p>"
            elif tag_name == "p":
                if text:
                    if child.attrib.get("class") == "subtitle":
                        html_content += f"<p class='centered'>{escape(text)}</p>"
                    else:
                        html_content += f"<br><br> {escape(text)}"
            elif tag_name in {"party", "organization"}:
                if text:
                    if child.attrib.get("class") == "subtitle":
                        html_content += f"<br><br><p class='centered'>{escape(text)}</p>"
                    else:
                        html_content += f" {escape(text)}"
            elif tag_name == "ref":
                href = child.attrib.get("href", "#")
                link_text = escape(child.text.strip()) if child.text else ""
                if href.startswith("/krivicni#"):
                    section_id = href.split("#")[-1]
                    html_content += f' <a href="../../Laws/html/krivicni.html#{section_id}" target="_blank">{link_text}</a> '
                else:
                    html_content += f' <a href="{escape(href)}" target="_blank">{link_text}</a> '
            else:
                #ako nema child, samo dodati text
                if len(child) == 0 and text:
                    html_content += f" {escape(text)}"
            
            # obrada tail teksta nakon tagova
            if child.tail:
                tail_text = child.tail.strip()
                if tail_text:
                    html_content += f" {escape(tail_text)}"

            

    
    html_content += """
    </body>
    </html>
    """

    
    with open(output_html, "w", encoding="utf-8") as f:
        f.write(html_content)

    return html_content






def law_xml_act_to_html(xml_file, output_html):
    namespaces = {'akn': 'http://docs.oasis-open.org/legaldocml/ns/akn/3.0/WD17'}

    tree = ET.parse(xml_file)
    root = tree.getroot()

    # meta podaci
    act_name = root.find(".//akn:act", namespaces).attrib.get("name", "Naziv nije dostupan")

    frbr_date = root.find(".//akn:FRBRdate", namespaces).attrib.get("date", "")
    frbr_date = format_date(frbr_date)

    publication = root.find(".//akn:publication", namespaces)
    publication_info = (f"{publication.attrib.get('showAs', '')}, {format_date(publication.attrib.get('date', ''))}, бр. {publication.attrib.get('number', '')}" 
                        if publication is not None else "Sluzbeni podaci nisu dostupni")

   
    html_content = f"""
    <!DOCTYPE html>
    <html lang='sr'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>{escape(act_name)}</title>
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; margin: 20px; }}
            h1, h4 {{ text-align: center; margin: 0; }}
            h4 {{ color: gray; }}
            p {{ text-align: justify; }}
            .article-header {{ font-weight: bold; margin-top: 10px; }}
            .number {{ font-weight: bold; }}
        </style>
    </head>
    <body>
        <h1>{escape(act_name)}</h1>
        <h4>{escape(publication_info)}</h4>
        <h4>{escape(frbr_date)}</h4>
        <br><br>
    """

   
    body = root.find(".//akn:body", namespaces)
    for chapter in body.findall(".//akn:chapter", namespaces):
        chapter_num = chapter.find("./akn:num", namespaces).text.strip() if chapter.find("./akn:num", namespaces) is not None else ""
        chapter_heading = chapter.find("./akn:heading", namespaces).text.strip() if chapter.find("./akn:heading", namespaces) is not None else ""
        
        # id glave
        chapter_id = chapter.attrib.get('eId', '')


        html_content += f"<h2 id='{chapter_id}' style='text-align: center;'><span style='font-weight: bold; font-style: italic;'>{escape(chapter_num)}</span><br><span style='font-weight: normal'>{escape(chapter_heading)}</span></h2><br>"

        for section in chapter.findall(".//akn:section", namespaces):
            section_num = section.find("./akn:num", namespaces).text.strip() if section.find("./akn:num", namespaces) is not None else ""
            section_heading = section.find("./akn:heading", namespaces).text.strip() if section.find("./akn:heading", namespaces) is not None else ""
            
            section_in_chp_id = section.attrib.get('eId', '')
            
            if section_num or section_heading:
                html_content += f"<h3 id='{section_in_chp_id}' style='text-align: center;'><span style='font-weight: normal; font-style: italic;'>{escape(section_num)} {escape(section_heading)}</span></h3>"

            for article in section.findall("./akn:article", namespaces):
                article_num = article.find("./akn:num", namespaces).text.strip() if article.find("./akn:num", namespaces) is not None else ""
                article_heading = article.find("./akn:heading", namespaces).text.strip() if article.find("./akn:heading", namespaces) is not None else ""
                
                # id clana
                article_id = article.attrib.get('eId', '')
                
                html_content += f"<h3 id='{article_id}' style='text-align: center;'><span style='font-weight: bold;'>{escape(article_heading)}<br>{escape(article_num)}</span></h3>"

                for paragraph in article.findall("./akn:paragraph", namespaces):
                    paragraph_num = paragraph.find("./akn:num", namespaces).text.strip() if paragraph.find("./akn:num", namespaces) is not None else ""
                    # id stava
                    paragraph_id = paragraph.attrib.get('eId', '') 

                    #intro ako postoji
                    intro_text_elements = paragraph.findall("./akn:intro/akn:p", namespaces)
                    for intro_text_element in intro_text_elements:
                        intro_text = ''.join(intro_text_element.itertext()).strip()  
                        if intro_text:
                            for ref in intro_text_element.findall(".//akn:ref", namespaces):
                                ref_href = ref.attrib.get("href", "#")
                                ref_text = ref.text.strip() if ref.text else ""

                                if ref_href.startswith("/krivicni#"):
                                    section_id = ref_href.split("#")[-1]
                                    ref_text = f'<a href="#{section_id}">{ref_text}</a>'  
                                else:
                                    ref_text = f'<a href="{ref_href}">{ref_text}</a>'                               
                                intro_text = intro_text.replace(ref.text, ref_text)
                            html_content += f"<p id='{paragraph_id}'>{paragraph_num} {intro_text}</p>"

                    #stavovi ako imaju tacke
                    for point in paragraph.findall("./akn:point", namespaces):
                        point_num = point.find("./akn:num", namespaces).text.strip() if point.find("./akn:num", namespaces) is not None else ""
                        point_content = ''.join(point.itertext()).strip()  # uzimam sav text tacke ukljcujuci ref tagove

                        # id tacke
                        point_id = point.attrib.get('eId', '')
                        if point_content:
                            # radi dupliranje point_num
                            point_content = point_content.replace(point_num, '').strip()

                            for ref in point.findall(".//akn:ref", namespaces):
                                ref_href = ref.attrib.get("href", "#")
                                ref_text = ref.text.strip() if ref.text else ""

                                if ref_href.startswith("/krivicni#"):
                                    section_id = ref_href.split("#")[-1]
                                    ref_text = f'<a href="#{section_id}">{ref_text}</a>'  
                                else:
                                    ref_text = f'<a href="{ref_href}">{ref_text}</a>'
                                point_content = point_content.replace(ref.text, ref_text) 

                            html_content += f"<p id='{point_id}'>{point_num} {point_content}</p>"

                    #sadrzaj stava koji nema tacke
                    paragraph_text_elements = paragraph.findall("./akn:content/akn:p", namespaces)
                    for paragraph_text_element in paragraph_text_elements:
                        paragraph_text = ''.join(paragraph_text_element.itertext()).strip()
                        
                        if paragraph_text:
                            for ref in paragraph_text_element.findall(".//akn:ref", namespaces):
                                ref_href = ref.attrib.get("href", "#")
                                ref_text = ref.text.strip() if ref.text else ""

                                if ref_href.startswith("/krivicni#"):  
                                    section_id = ref_href.split("#")[-1]
                                    ref_text = f'<a href="#{section_id}">{ref_text}</a>'
                                else:  
                                    ref_text = f'<a href="{ref_href}">{ref_text}</a>'
                                paragraph_text = paragraph_text.replace(ref.text, ref_text)
                            
                            html_content += f"<p id='{paragraph_id}'>{escape(paragraph_num)} {paragraph_text}</p>"


    html_content += """
    </body>
    </html>
    """

    with open(output_html, "w", encoding="utf-8") as f:
        f.write(html_content)












#kod za prevodjenje presuda u html

# input_folder = "Verdicts/akoma-ntoso"
# output_folder = "Verdicts/html"

# if not os.path.exists(output_folder):
#     os.makedirs(output_folder)

# for filename in os.listdir(input_folder):
#     if filename.endswith(".xml"):
#         input_path = os.path.join(input_folder, filename)
#         output_path = os.path.join(output_folder, filename.replace(".xml", ".html"))
#         print(f"Obrada fajla: {filename}")
#         try:
#             verdict_xml_to_html(input_path, output_path)
#             print(f"Generisan HTML: {output_path}")
#         except Exception as e:
#             print(f"Greska pri obradi fajla {filename}: {e}")


#kod za prevodjenje krivicnog zakona u html
# if __name__ == "__main__":
#     input_folder = "pravna/src/main/resources/law_and_verdicts/"
#     output_folder = "pravna/src/main/resources/law_and_verdicts/law_html/"
    
#     if not os.path.exists(output_folder):
#         os.makedirs(output_folder)

    
#     filename = "criminal_law_acoma_ntoso.xml"
#     if filename.endswith(".xml"):
#         input_path = os.path.join(input_folder, filename)
#         output_path = os.path.join(output_folder, filename.replace(".xml", ".html"))
#         print(f"Obrada fajlaa: {filename}")
#         try:
#             law_xml_act_to_html(input_path, output_path)
#             print(f"Generisan HTML: {output_path}")
#         except Exception as e:
#             print(f"Greska pri obradi fajla {filename}: {e}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python akomaNtoso_to_html_translator.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]
    input_folder = "pravna/src/main/resources/law_and_verdicts/verdicts"
    output_folder = "pravna/src/main/resources/law_and_verdicts/verdicts/html"

    # print("Current working directory:", os.getcwd())

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # input_path = os.path.join(input_folder, filename + ".xml")
    # output_path = os.path.join(output_folder, filename.replace(".xml", ".html"))
    # input_path = input_folder + "/" + filename + ".xml"
    # output_path = output_folder

    input_path = Path(input_folder) / f"{filename}.xml"
    output_path = Path(output_folder) / f"{filename}.html"

    print(f"Obrada fajla: {filename}")
    try:
        verdictHTML = verdict_xml_to_html(input_path, output_path)
        print(f"Generisan HTML: {output_path}")
        print("===HTML_START===")
        print(verdictHTML)
        print("===HTML_END===")
    except Exception as e:
        print(f"Greska pri obradi fajla {filename}: {e}")