public class Rectangle implements Shape {

    private Double length = 0;
    private Double width = 0;

    // 생성자
    public Rectangle(Double n, Double w) {
        n = 1;
        length = n;
        width = w;
    }
    
    public Double getArea() {
        return length * width;
    } // getArea()

}