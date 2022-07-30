# Creates the doc.scheme.org page with formatted guide/ documentation
# 
# see rake -T for available options
# Requires 'asciidoctor' and 'rouge' (source-highlighter) to be installed

require 'asciidoctor'

CWD = File.expand_path(File.dirname(__FILE__))
SRC = File.join(CWD, '.')   # location of adoc files to include in guide

#  - title to use is read direct from adoc file, 
def get_page_title(page_name)
  Asciidoctor.load_file(File.join(SRC, "#{page_name}.adoc")).doctitle
end

# Returns the html header using the given 'title' as the top-level <h1>
# title.
# 'page_title' flag is set to fale to suppress use of title head/title, for the index page.
def header(title, page_title = true)
  html_title = if page_title
                 "Scheme Documentation: #{title}"
               else
                 "Scheme Documentation"
               end
  return <<END
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>#{html_title}</title>
  <link rel="stylesheet" href="/schemeorg.css">
  <link rel="stylesheet" href="/syntax.css">
  <meta name="viewport" content=
  "width=device-width, initial-scale=1">
  <link rel="icon" href="/favicon/favicon.svg" sizes="any" type=
  "image/svg+xml">
</head>
<body>
  <header>
    <ul class="menu">
      <li>
        <a href="https://www.scheme.org/">Home</a>
      </li>
      <li class="active">Docs</li>
      <li>
        <a href="https://community.scheme.org/">Community</a>
      </li>
      <li>
        <a href="https://standards.scheme.org/">Standards</a>
      </li>
      <li>
        <a href="https://get.scheme.org/">Implementations</a>
      </li>
    </ul>
  </header>
  <h1 id="logo">#{title}</h1>
END
end

# Returns HTML footer
def footer
  return <<END
<h2>Contributing</h2>
  <section id="schemeorg-contributing" class="round-box green-box">
    <p><kbd>doc.scheme.org</kbd> is a community subdomain of
    <kbd>scheme.org</kbd>.</p>
    <ul>
      <li>Source code: <a href=
      "https://github.com/schemedoc"><kbd class=
      "github-org">schemedoc</kbd> organization</a> on GitHub.
      </li>
      <li>Discussion: <code class="mailing-list">schemedoc</code>
      mailing list (<a href=
      "https://srfi-email.schemers.org/schemedoc/">archives</a>,
      <a href=
      "https://srfi.schemers.org/srfi-list-subscribe.html#schemedoc">
        subscribe</a>), GitHub issues.
      </li>
    </ul>
  </section>
</body>
</html>
END
end

# -----------------------------------------------------------------------------
# Apply asciidoctor on every file in SRC to create the .html shells
# If update? is true, then first checks if .adoc file is a new file or 
# has newer time than its .html file, and only converts if so.
def make_shells(update=false)
  Dir.chdir(SRC) do
    Dir.foreach('.') do |file|
      next unless file.end_with? 'adoc'
      if update
        target = file.sub(/adoc\Z/, 'html')
        if !File.exist?(target) or File.mtime(target) < File.mtime(file)
          puts "Updating file: #{file}"
          `asciidoctor -a source-highlighter=rouge -s #{file}`
        end
      else
        puts "Converting file: #{file}"
        `asciidoctor -a source-highlighter=rouge -s #{file}`
      end
    end
  end
end

# Works through files in SRC and makes a complete HTML page in 'www'
# attaching the header and footer.
# Each page.html is placed into page/index.html for page/ links
def make_pages() 
  Dir.mkdir('www') unless Dir.exist?('www')
  Dir.mkdir('www/guide') unless Dir.exist?('www/guide')
  Dir.foreach(SRC) do |file|
    next unless file.end_with? 'html'
    puts "make page: #{file}"
    page_name = file.gsub('.html', '')
    page_dir = File.join('www', 'guide', page_name)
    Dir.mkdir(page_dir) unless Dir.exist?(page_dir)

    File.open(File.join(page_dir, 'index.html'), "w") do |site_file|
      # output header
      title = get_page_title(page_name)
      site_file.puts header(title)

      # output shell
      IO.foreach(File.join(SRC, file)) do |line|
        site_file.puts line
      end
      # output footer
      site_file.puts footer
    end
  end
end

# Creates the index page for 'docs.scheme.org', with an automatically 
# completed list of 'Scheme Guide' links
def make_index_page
  puts "make page: index.html"
  File.open(File.join('www', 'guide', 'index.html'), "w") do |index_file|
    # output header
    index_file.puts header('Scheme Docs', false)

    # Create Scheme Guide list
    index_file.puts '<h2>Scheme Guide</h2>'
    index_file.puts '<ul>'
    Dir.foreach(SRC) do |file|
      next unless file.end_with? 'html'
      page_name = file.gsub('.html', '')
      page_title = get_page_title(page_name)

      index_file.puts "<li><a href=\"/guide/#{page_name}/\">#{page_title}</li>"
    end
    index_file.puts '</ul>'

    # Output remaining links
    index_file.puts <<END
<h2>Scheme Requests for Implementation (SRFI)</h2>
  <p><a href="srfi/library-names/">Library names</a></p>
  <p><a href="srfi/support/">Support table</a></p>
  <h2>More tools</h2>
  <p><a href="//cookbook.scheme.org/" class=
  "offsite">Cookbook</a></p>
  <p><a href="//man.scheme.org/" class="offsite">Manual pages (Unix
  style)</a></p>
  <p><a href="surveys/">Surveys</a></p>
END
    # Output footer
    index_file.puts footer
  end
end

# Top-level function makes the entire website
# - set update to true to only update changed pages
def make_site(update=false)
  make_shells(update)
  make_pages
  make_index_page
end

# -----------------------------------------------------------------------------
# Tasks

desc 'build web site afresh'
task :build => [:clean] do
  make_site
  cp 'schemeorg.css', 'www'
  cp 'syntax.css', 'www'
end

desc 'clean up directory'
task :clean do
  FileUtils.rm Dir.glob("#{SRC}/*.html"), force: true
  FileUtils.rm_rf 'www'
end

desc 'show web www - port 8000'
task :show do
  Dir.chdir('www') do
    `ruby -run -ehttpd . -p8000`
  end
end

# update task
# check time of .adoc vs .html and only convert if necessary
desc 'update revised or new files only'
task :update do
  make_site true
end

