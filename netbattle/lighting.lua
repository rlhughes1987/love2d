local distance_shading_code = [[
#define NUM_LIGHTS 32

struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
};

extern Light lights[NUM_LIGHTS];
extern int num_lights;

extern vec2 screen;

const float constant = 1.0;
const float linear = 0.09;
const float quadratic = 0.032;

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
    vec4 pixel = Texel(image, uvs);

    vec2 norm_screen = screen_coords / screen;
    vec3 diffuse = vec3(0);

    for (int i = 0; i < num_lights; i++) {
        Light light = lights[i];
        vec2 norm_pos = light.position / screen;
        
        float distance = length(norm_pos - norm_screen) * light.power;
        float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));
        diffuse += light.diffuse * attenuation;
    }

    diffuse = clamp(diffuse, 0.0, 1.0);

    return pixel * vec4(diffuse, 1.0);
}

]]

local god_ray_code = [[
extern number decay;
extern number density;
extern number weight;
extern vec2 lightPositionOnScreen;
//uniform sampler2D firstPass;
const number NUM_SAMPLES = 100 ;

 vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{

  vec2 deltaTextCoord = texture_coords - lightPositionOnScreen;
 
  deltaTextCoord *= 1.0 / float(NUM_SAMPLES) * density;
  number illuminationDecay = 1.0;
  vec2 textCoo=texture_coords;
 
  vec4 result=texture2D(texture, textCoo );
  for(int i=0; i < NUM_SAMPLES ; i++)
   {
     	  textCoo -= deltaTextCoord;
     	  vec4 sample = texture2D(texture, textCoo );
          sample *= illuminationDecay * weight;
          result += sample;
          illuminationDecay *= decay;
  } 
  return result;
}]]


local crt_monitor_code = [[
    extern vec2 distortionFactor;
    extern vec2 scaleFactor;
    extern number feather;

    vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px) {
      // to barrel coordinates
      uv = uv * 2.0 - vec2(1.0);

      // distort
      uv *= scaleFactor;
      uv += (uv.yx*uv.yx) * uv * (distortionFactor - 1.0);
      number mask = (1.0 - smoothstep(1.0-feather,1.0,abs(uv.x)))
                  * (1.0 - smoothstep(1.0-feather,1.0,abs(uv.y)));

      // to cartesian coordinates
      uv = (uv + vec2(1.0)) / 2.0;

      return color * Texel(tex, uv) * mask;
    }
  ]]



local lighting = {
    distance_shading = { shader = love.graphics.newShader(distance_shading_code), distance_lights = {} },
    godray_shading = { shader = love.graphics.newShader(god_ray_code), ray = nil },
    crt_shading = { shader = love.graphics.newShader(crt_monitor_code), crt = nil }
--extend
}

function lighting.reset()
    lighting.distance_shading.distance_lights = {}
    lighting.godray_shading.ray = {}
    lighting.crt_shading.crt = {}
end

function lighting.addDistanceLight(light, power, r, g, b) -- pass light object and assign power and colour
    local powered_light = { lightobj = light, power = power, r = r, g = g, b = b}
    table.insert(lighting.distance_shading.distance_lights,powered_light)
end

function lighting.addGodRay(light, decay, density, weight)
    local godray = {lightobj = light, decay = decay, density = density, weight = weight}
    lighting.godray_shading.ray = godray
end

function lighting.addCRTShading(light)
    local crt = { lightobj = light }
    lighting.crt_shading.crt = crt
end

function lighting.StartCRTShading()
    if lighting.crt_shading.crt.lightobj.enabled then
        local shader = lighting.crt_shading.shader
        love.graphics.setShader(shader)
        shader:send("distortionFactor", {1.06, 1.065})
        shader:send("scaleFactor", {1, 1})
        shader:send("feather", 0.02)
    end
end

function lighting.startGodrayShading()
    if lighting.godray_shading.ray.lightobj.enabled then
        local ofs = {0,0}
        --ofs[0], ofs[1] = love.graphics.transformPoint(lighting.godray_shading.ray.lightobj.x,lighting.godray_shading.ray.lightobj.y)
        local shader = lighting.godray_shading.shader
        love.graphics.setShader(shader)
        shader:send("decay", lighting.godray_shading.ray.decay)
        shader:send("density", lighting.godray_shading.ray.density)
        shader:send("weight", lighting.godray_shading.ray.weight)
        --shader:send("lightPositionOnScreen", ofs)
        shader:send("lightPositionOnScreen", {0,0})
    end
end

function lighting.startDistanceShading()
    local shader = lighting.distance_shading.shader
    love.graphics.setShader(shader)
    shader:send("screen", {
        love.graphics.getWidth(),
        love.graphics.getHeight()
    })
    -- count all the lights that are enabled
    local num_lights = 0
    local powered_distance_lights = lighting.distance_shading.distance_lights
    for j=1, #powered_distance_lights do
        if powered_distance_lights[j].lightobj.enabled then
            num_lights = num_lights + 1
        end
    end
    shader:send("num_lights", num_lights)
    local ofs = {0,0}
    local index = 0 --c array index
    for i=1, #powered_distance_lights do
        if powered_distance_lights[i].lightobj.enabled then
            ofs[1], ofs[2] = love.graphics.transformPoint(powered_distance_lights[i].lightobj.x,powered_distance_lights[i].lightobj.y) -- to avoid light following camera (apaz this is not good as uses CPU)
            local name = "lights[" .. index .."]"
            shader:send(name .. ".position", ofs)
            shader:send(name .. ".diffuse", {powered_distance_lights[i].r, powered_distance_lights[i].g, powered_distance_lights[i].b})
            shader:send(name .. ".power", powered_distance_lights[i].power)
            index = index + 1
        end
    end
end

function lighting.endShading()
    love.graphics.setShader()
end


return lighting