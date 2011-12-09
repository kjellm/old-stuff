$(document).ready(function() {
    if (window.location.pathname === "/restricted/wopy/") {
        window.location.replace("/restricted/wopy/photo/");
    }
    return main();
});


function main() {
    write_initial_html();
    load_images();

    $("#slideshow").bind("click", slideshow);
    $("#slideshow-pane").bind("click", slideshow_img_clicked);

    set_parent_href_in_menu();
    remove_link_to_parent_from_file_list();

    return null;
}


function write_initial_html() {
    $("ul").attr("id", "file-listing");
    var body_html = $("body").html();
    $("body").html(
          "<div id=\"slideshow-pane\"><img id=\"slideshow-img\" src=\"\" alt=\"\"></div>\n"
        + "<div id=\"main\">"
        + "  <ul id=\"menu\">\n"
        + "    <li><a href=\"#\" id=\"slideshow\">Run slideshow</a>\n"
        + "    <li><a href=\"#\" id=\"parent\">Parent directory</a>\n"
        + "  </ul>\n"
        +    body_html
        + "<div id=\"main\">\n"
    );
}


function slideshow_img_clicked(event) {
    var src = $("#slideshow-img").attr("src");
    if (event.pageX < 200) {
        show_image(find_previous_image(src));
    }
    else if (event.pageX > 600) {
        show_image(find_next_image(src));
    }
    else {
        show_main_pane();
    }
}


function find_previous_image(src) {
    return $("img", $("li img[src=" + src + "]").closest("li").prev()).get(0);
}

function find_next_image(src) {
    return $("img", $("li img[src=" + src + "]").closest("li").next()).get(0);
}


function image_foo() {
    var images = $("#main img");
    var i = 0;
    var foo = function() {
        var img = images[i];
        $("#slideshow-img").attr('src', img.src);
        if (i < images.length && $("#slideshow-pane").css("display") === "block") {
            setTimeout(foo, 3000);
        }
        i++;
    };
    foo();
}


function slideshow(event) {
    event.preventDefault();
    show_slideshow_pane();
    image_foo();
}


function show_slideshow_pane() {
    $("#slideshow-pane").css("display", "block");
    $("#main").css("display", "none");
}


function show_main_pane() {
    $("#slideshow-pane").css("display", "none");
    $("#main").css("display", "block");
}


function load_images() {
    $("a[href$=jpg]").each(function() {
        $(this).html("<img class=\"thumbnail\" src=\"" + $(this).attr('href') + "\" alt=\"\">");
        $(this).bind("click", image_thumbnail_clicked);
    });

}


function image_thumbnail_clicked(event) {
    event.preventDefault();
    show_slideshow_pane();
    show_image(event.target);

}


function show_image(img) {
    if(img === undefined) return;
    $("#slideshow-img").attr('src', img.src);
}


function set_parent_href_in_menu() {
    $("#parent").attr("href", $("a:contains('Parent Directory')").attr("href"));
}


function remove_link_to_parent_from_file_list() {
    $("li:contains('Parent Directory')").remove();
}
