using UnityEngine;

public class CubeControl : MonoBehaviour
{
    [Range(.1f, 10)]
    public float scale = 1;

    [Range(0,1)]
    public float rotateSpeed;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.localScale = Vector3.one * scale;
        transform.Rotate(Vector3.up, rotateSpeed * Time.deltaTime * 360);
    }
}
