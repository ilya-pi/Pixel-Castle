import java.util.List;

public class Level {

    private final Pixel[][] pixels;
    private final String levelName;
    private final int levelHeight;
    private final int levelWidth;
    private final int pixelsSkipFromTop;
    private final Castle castle1;
    private final Castle castle2;

    public Level(Pixel[][] pixels, int height, int width, String levelName, Castle castle1, Castle castle2, int pixelsSkipFromTop) {
        this.pixels = pixels;
        this.levelHeight = height;
        this.levelWidth = width;
        this.castle1 = castle1;
        this.castle2 = castle2;
        this.pixelsSkipFromTop = pixelsSkipFromTop;
        this.levelName = levelName;
    }

    public static class Pixel {
        private int[] rgba;
        private int hl;

        public Pixel(int[] rgba, int health) {
            if (rgba.length != 4) {
                throw new IllegalStateException("rgba should consist of 3 colors and opacity");
            }
            this.rgba = rgba;
            this.hl = health;
        }

        public int[] getRgba() {
            return rgba;
        }

        public int getHl() {
            return hl;
        }
    }

    public static class Castle {

        private final int height;
        private final int width;

        //top left corner
        private final int x;
        private final int y;

        public Castle(int width, int height, int x, int y) {
            this.height = height;
            this.width = width;
            this.x = x;
            this.y = y;
        }

        public int getHeight() {
            return height;
        }

        public int getWidth() {
            return width;
        }

        public int getX() {
            return x;
        }

        public int getY() {
            return y;
        }
    }

    public Pixel[][] getPixels() {
        return pixels;
    }

    public String getLevelName() {
        return levelName;
    }

    public int getLevelHeight() {
        return levelHeight;
    }

    public int getLevelWidth() {
        return levelWidth;
    }

    public int getPixelsSkipFromTop() {
        return pixelsSkipFromTop;
    }

    public Castle getCastle1() {
        return castle1;
    }

    public Castle getCastle2() {
        return castle2;
    }
}
