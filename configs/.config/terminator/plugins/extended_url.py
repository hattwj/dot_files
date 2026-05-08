"""extended_url.py - URL handler plugin that supports query parameters and fragments"""
import terminatorlib.plugin as plugin

# Required for Terminator to discover this plugin
AVAILABLE = ['ExtendedURLHandler']


class ExtendedURLHandler(plugin.URLHandler):
    """URL handler that matches full URLs including query params (?key=val&key2=val2)
    and fragment identifiers (#section). Based on the APTURLHandler pattern."""
    capabilities = ['url_handler']
    handler_name = 'extended_url'
    nameopen = "Open URL"
    namecopy = "Copy URL"

    # Match http/https URLs with:
    #   - path segments (including encoded chars like %20)
    #   - query parameters (?foo=bar&baz=qux)
    #   - fragment identifiers (#section)
    # Excludes trailing punctuation that's likely not part of the URL
    match = r'https?://[^\s<>"{}|\\^`\[\]]+[^\s<>"{}|\\^`\[\].,;:!?\)\]\}>\'"]'

    def callback(self, url):
        """Return the matched URL as-is"""
        return url
